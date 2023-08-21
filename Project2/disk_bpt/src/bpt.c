#include "bpt.h"

H_P * hp;

page * rt = NULL; //root is declared as global

int fd = -1; //fd is declared as global

H_P * load_header(off_t off) {
    H_P * newhp = (H_P*)calloc(1, sizeof(H_P));
    if (sizeof(H_P) > pread(fd, newhp, sizeof(H_P), 0)) {
        // pread의 반환값은 읽은 데이터의 크기 ... 만약에 H_P 보다 작으면 헤더조차 없는거니까 null
        return NULL;
    }
    // 있으면 헤더 반환
    return newhp;
}

page * load_page(off_t off) {
    page* load = (page*)calloc(1, sizeof(page));
    if (off % sizeof(page) != 0) printf("load fail : page offset error\n"); //print
    if (sizeof(page) > pread(fd, load, sizeof(page), off)) {
        // 페이지 읽고 없으면 null
        return NULL;
    }
    return load;
}

int open_table(char * pathname) {
    fd = open(pathname, O_RDWR | O_CREAT | O_EXCL | O_SYNC  , 0775); //파일을 여는 함수 읽기쓰기가능,해당파일이 없으면 생성, 이미 파일이 존재하면 열기 불가
    hp = (H_P *)calloc(1, sizeof(H_P)); // 헤더페이지 할당
    // 위의 조건에 파일을 처음 생성해야 fd=1 이 된다.
    if (fd > 0) {
        // 새로운 파일 생성
        hp->fpo = 0;
        hp->num_of_pages = 1;
        hp->rpo = 0;
        // 헤더포인터 초기화
        pwrite(fd, hp, sizeof(H_P), 0);
        free(hp);
        hp = load_header(0); // 헤더 파일에서 로드
        return 0;
    }
    fd = open(pathname, O_RDWR|O_SYNC); // 파일이 이미 있는 파일 열기
    if (fd > 0) {
        //printf("Read Existed File\n");
        if (sizeof(H_P) > pread(fd, hp, sizeof(H_P), 0)) {
            // 헤더 읽고 없으면 -1
            return -1;
        }
        off_t r_o = hp->rpo; // 헤더의 rpo값 가져오기
        rt = load_page(r_o); // rpo 에 해당하는 페이지 offset으로 페이지 읽기
        return 0;
    }
    else return -1;
}

void reset(off_t off) {
    page * reset;
    reset = (page*)calloc(1, sizeof(page));
    reset->parent_page_offset = 0;
    reset->is_leaf = 0;
    reset->num_of_keys = 0;
    reset->next_offset = 0;
    pwrite(fd, reset, sizeof(page), off);
    free(reset);
    return;
}

void freetouse(off_t fpo) {
    // fpo에 해당하는 페이지를 초기화 한 뒤 db에 write 한다.
    page * reset;
    reset = load_page(fpo);
    reset->parent_page_offset = 0;
    reset->is_leaf = 0;
    reset->num_of_keys = 0;
    reset->next_offset = 0;
    pwrite(fd, reset, sizeof(page), fpo);
    free(reset);
    return;
}

void usetofree(off_t wbf) {
    page * utf = load_page(wbf);
    utf->parent_page_offset = hp->fpo;
    utf->is_leaf = 0;
    utf->num_of_keys = 0;
    utf->next_offset = 0;
    pwrite(fd, utf, sizeof(page), wbf);
    free(utf);
    hp->fpo = wbf;
    pwrite(fd, hp, sizeof(hp), 0);
    free(hp);
    hp = load_header(0);
    return;
}

off_t new_page() {
    off_t newp;
    page * np;
    off_t prev;
    if (hp->fpo != 0) {
        // 이전의 정보가 남아 있다면?
        newp = hp->fpo;
        np = load_page(newp); // 해당 페이지 불러오기
        hp->fpo = np->parent_page_offset; // freepage 를 parent page 로 바꿔주고
        pwrite(fd, hp, sizeof(hp), 0); // 해당 페이지 디스크에 작성
        free(hp); // 메모리에선 해당 데이터 삭제
        hp = load_header(0); // 오프셋 0으로 다시
        free(np);
        freetouse(newp);
        return newp;
    }
    //change previous offset to 0 is needed
    newp = lseek(fd, 0, SEEK_END);
    //if (newp % sizeof(page) != 0) printf("new page made error : file size error\n");
    reset(newp);
    hp->num_of_pages++;
    pwrite(fd, hp, sizeof(H_P), 0);
    free(hp);
    hp = load_header(0);
    return newp;
}

off_t find_leaf(int64_t key) {
    int i = 0;
    page * p;
    off_t loc = hp->rpo;

    //printf("left = %ld, key = %ld, right = %ld, is_leaf = %d, now_root = %ld\n", rt->next_offset, 
    //  rt->b_f[0].key, rt->b_f[0].p_offset, rt->is_leaf, hp->rpo);

    if (rt == NULL) {
        printf("Empty tree.\n"); // print
        return 0;
    }
    p = load_page(loc); // 루트에 해당하는 페이지 로드

    while (!p->is_leaf) { // 리프가 아니라면~?
        i = 0;

        // 키가 들어갈 인텍스 찾기
        while (i < p->num_of_keys) {
            if (key >= p->b_f[i].key) i++;
            else break;
        }

        if (i == 0) loc = p->next_offset;
        else
            loc = p->b_f[i - 1].p_offset;
        //if (loc == 0)
        // return NULL;

        free(p);
        p = load_page(loc);

    }

    free(p);
    // 해당하는 오프셋 반환
    return loc;

}

void print_tree() {
    if(rt == NULL) {
        printf("EmptyTree\n");
        return;
    }

    print_tree_start(hp->rpo);
}

void print_tree_start(off_t page_off) {
    // 출력할 페이지의 오프셋을 넘겨받고 페이지 로드
    int i=0;
    page * p;
    p = load_page(page_off);

    if(p->is_leaf) {
        // 넘겨받은 페이지가 리프라면 출력하고 끝
        printf("leaf ");
        while(i < p->num_of_keys) {
            printf("%lld ", p->records[i].key);
            i++;
        }
        printf("\n");
        return;
    } else {
        // 넘겨받은 페이지가 인터널이라면 일단 출력하고
        printf("internal "); 
        while(i < p->num_of_keys) {
                printf("%lld ", p->b_f[i].key);
                i++;
            }
            printf("\n");
    }

    // 자식 페이지에 대해서 재귀적으로 출력 다시
    int page_index = 0;
    print_tree_start(p->next_offset);
    while (page_index < p->num_of_keys)
    {
        printf("%d / %d : ", page_index, p->num_of_keys); // 현재 페이지/전체 페이지 : 
        print_tree_start(p->b_f[page_index].p_offset);
        page_index++;
    }
}

char * db_find(int64_t key) {
    char * value = (char*)malloc(sizeof(char) * 120);
    int i = 0;
    off_t fin = find_leaf(key);
    if (fin == 0) {
        return NULL;
    }
    page * p = load_page(fin);

    for (; i < p->num_of_keys; i++) {
        if (p->records[i].key == key) break;
    }
    if (i == p->num_of_keys) {
        free(p);
        return NULL;
    }
    else {
        strcpy(value, p->records[i].value);
        free(p);
        return value;
    }
}

int cut(int length) {
    if (length % 2 == 0)
        return length / 2;
    else
        return length / 2 + 1;
}

void start_new_file(record rec) {

    page * root;
    off_t ro;
    ro = new_page(); // 새로운 페이지 생성하고 오프셋 반환
    rt = load_page(ro); // 새로 받은 오프셋에 대한 페이지 load
    hp->rpo = ro; // 루트로 지정
    pwrite(fd, hp, sizeof(H_P), 0); // 새로 만들어진 페이지 쓰기
    free(hp);
    hp = load_header(0); // 헤더에 연결해줄 페이지
    rt->num_of_keys = 1;
    rt->is_leaf = 1;
    rt->records[0] = rec;
    pwrite(fd, rt, sizeof(page), hp->rpo);
    free(rt);
    rt = load_page(hp->rpo);
    //printf("new file is made\n");
}

int db_insert(int64_t key, char * value) {

    record nr; //key+value
    nr.key = key;
    strcpy(nr.value, value);
    // 구조체에 입력받은 데이터 저장
    if (rt == NULL) {
        // rt == null -> 현재 읽고 있는 페이지가 없음 .. 새로운 페이지 파일 생성
        start_new_file(nr);
        return 0;
    }

    // 이미 있는건지 아닌지 체크
    char * dupcheck;
    dupcheck = db_find(key);
    if (dupcheck != NULL) {
        free(dupcheck);
        return -1;
    }
    free(dupcheck);

    // 해당하는 키가 들어갈 오프셋
    off_t leaf = find_leaf(key);

    page * leafp = load_page(leaf);

    if (leafp->num_of_keys < LEAF_MAX) {
        // 리프에 자리가 있다면 넣고 끝
        insert_into_leaf(leaf, nr);
        free(leafp);
        leafp = load_page(leaf);

        // redistribution 을 할 수 있는지 확인
        // 조건1 - 인서트가 일어난 리프의 요소 갯수가 절반을 넘는지. 
        if(leafp->num_of_keys == LEAF_MAX && leaf!=hp->rpo) {
            // 넘는다면 이웃에 대한 정보를 불러온다. 
            int neighbor_index, k_prime_index;
            off_t neighbor_offset, parent_offset;
            int64_t k_prime;
            parent_offset = leafp->parent_page_offset;
            page * parent = load_page(parent_offset);

            // 만약에 인서트가 일어난 리프가 맨 왼쪽이라면 
            if(parent->next_offset == leaf) {
                // 이웃 인덱스 = -2
                neighbor_index = -2;
                neighbor_offset = parent->b_f[0].p_offset;
                k_prime = parent->b_f[0].key;
                k_prime_index = 0;
            }else if(parent->b_f[0].p_offset == leaf) {
                // 지워진 페이지가 children 중에서 두번째 페이지 일떼?
                neighbor_index = -1;
                // 이웃 노드는 첫번재 노드
                neighbor_offset = parent->next_offset;
                k_prime_index = 0;
                k_prime = parent->b_f[0].key;
            }
            else {
                // 나머지
                int i;
                // 지워진 페이지에 대한 인덱스 찾기
                for (i = 0; i <= parent->num_of_keys; i++)
                    if (parent->b_f[i].p_offset == leaf) break;
                // 지워진 노드의 왼쪽이 이웃 노드
                neighbor_index = i - 1;
                neighbor_offset = parent->b_f[i - 1].p_offset;
                k_prime_index = i;
                k_prime = parent->b_f[i].key;
            }

            // 이웃노드 갯수 가 맥스보다 작다면
            page * neighbor = load_page(neighbor_offset);
            
            free(neighbor);
            free(leafp);
            free(parent);

            if(neighbor->num_of_keys < LEAF_MAX) {
                redistribution_pages_insert(leaf,neighbor_index,neighbor_offset,parent_offset,k_prime,k_prime_index);
            }
            return 0;
        }
        free(leafp);
        return 0;
    } 

    // 리프에 자리가 없다면
    insert_into_leaf_as(leaf, nr);
    free(leafp);
    //why double free?
    return 0;

}

void redistribution_pages_insert(off_t inserted_node, int nbor_index, off_t nbor_off, off_t par_off, int64_t k_prime, int k_prime_index) {
    // 요소가 추가되어 재분배가 필요한 노드, 이웃 노드의 순서, (-2 -1 0 1 2 ..), 이웃 노드의 offset, 부모 오프셋, 옮겨갈 숫자, 부모에서 그 숫자의 인덱스
    page *inserted, *nbor, *parent;
    int i;
    inserted = load_page(inserted_node);
    nbor = load_page(nbor_off);
    parent = load_page(par_off);

    if(nbor_index != -2) {
        // 맨 왼쪽이 아닐 때
        if(!inserted->is_leaf) {
            // leaf가 아님
            // inserted의 제일 왼쪽 key를 nbor에 넘긴다.
            // nbor의 맨 마지막 요소의 키를 k_prime 으로
            nbor->b_f[nbor->num_of_keys].key = k_prime;
            // nbor의 맨 마지막 요소의 오프셋을 inserted의 맨 앞 오프셋으로
            nbor->b_f[nbor->num_of_keys].p_offset = inserted->next_offset;
            // 해당 페이지 로드 후 부모를 이웃 노드로 수정해주고 저장
            page * child = load_page(nbor->b_f[nbor->num_of_keys].p_offset);
            child->parent_page_offset = nbor_off;
            pwrite(fd,child,sizeof(page),nbor->b_f[nbor->num_of_keys].p_offset);
            free(child);

            // 부모의 요소를 바뀐 inserted의 맨 앞껄로 바꿔줌 
            parent->b_f[k_prime_index].key = inserted->b_f[0].key; // todo 밑줄로 옮겨야 하는거 아닌가..
            // inserted의 맨 처음 오프셋을 원래 두번째 꺼 였던걸로 바꿔줌
            inserted->next_offset = inserted->b_f[0].p_offset;
            // 이후 한칸씩 땡김
            for(i=0 ; i<inserted->num_of_keys-1 ; i++) {
                inserted->b_f[i] = inserted->b_f[i+1];
            }
        } else {
            // leaf 일 때
            // inserted 의 record 한칸씩 땡기고
            nbor->records[nbor->num_of_keys] = inserted->records[0];
            for(int i=0 ; i<inserted->num_of_keys-1 ; i++) {
                inserted->records[i] = inserted->records[i+1];
            }
            parent->b_f[k_prime_index].key = inserted->records[0].key;
        }
    } else {
        if(inserted->is_leaf) {
            for(i = nbor->num_of_keys ; i>0 ; i--) {
                nbor->records[i] = nbor->records[i-1];
            }
            nbor->records[0] = inserted->records[inserted->num_of_keys - 1];
            inserted->records[inserted->num_of_keys-1].key = 0;
            parent->b_f[k_prime_index].key = inserted->records[0].key;
        } else {
            for(i = nbor->num_of_keys ; i>0 ; i--) {
                nbor->b_f[i] = nbor->b_f[i-1];
            }
            nbor->b_f[0].key = k_prime;
            nbor->b_f[0].p_offset = nbor->next_offset;
            nbor->next_offset = inserted->b_f[inserted->num_of_keys-1].p_offset;
            page * child = load_page(nbor->next_offset);
            child->parent_page_offset = nbor_off;
            pwrite(fd,child,sizeof(page),nbor->next_offset);
            free(child);
            parent->b_f[k_prime_index].key = inserted->b_f[inserted->num_of_keys-1].key;
        }
    }

    nbor->num_of_keys++;
    inserted->num_of_keys--;

    pwrite(fd,parent,sizeof(page),par_off);
    pwrite(fd,nbor,sizeof(page),nbor_off);
    pwrite(fd,inserted,sizeof(page),inserted_node);

    free(parent); free(nbor); free(inserted);
    return ;
}

off_t insert_into_leaf(off_t leaf, record inst) {

    page * p = load_page(leaf);
    //if (p->is_leaf == 0) printf("iil error : it is not leaf page\n");
    int i, insertion_point;
    insertion_point = 0;
    // 반복문 돌며 들어갈 인덱스 찾기
    while (insertion_point < p->num_of_keys && p->records[insertion_point].key < inst.key) {
        insertion_point++;
    }
    // 한칸 씩 밀어서 공간 확보
    for (i = p->num_of_keys; i > insertion_point; i--) {
        p->records[i] = p->records[i - 1];
    }
    // 넣고 사이즈 증가
    p->records[insertion_point] = inst;
    p->num_of_keys++;
    // db 에 저장
    pwrite(fd, p, sizeof(page), leaf);
    //printf("insertion %ld is complete %d, %ld\n", inst.key, p->num_of_keys, leaf);
    free(p);
    return leaf;
}

off_t insert_into_leaf_as(off_t leaf, record inst) {

    off_t new_leaf;
    record * temp;
    int insertion_index, split, i, j;
    int64_t new_key;
    // 리프 분할을 위해 새로운 페이지 오프셋 생성
    new_leaf = new_page();
    // 오프셋에 해당하는 페이지 로드
    page * nl = load_page(new_leaf);
    nl->is_leaf = 1;
    temp = (record *)calloc(LEAF_MAX + 1, sizeof(record));
    if (temp == NULL) {
        perror("Temporary records array");
        exit(EXIT_FAILURE);
    }
    insertion_index = 0;
    page * ol = load_page(leaf); // Old leaf
    // 일단 인덱스 찾기
    while (insertion_index < LEAF_MAX && ol->records[insertion_index].key < inst.key) {
        insertion_index++;
    }
    // old leaf 에 있는 record 를 temp 에 백업 (이때 insertion_index 는 건너띄고 )
    for (i = 0, j = 0; i < ol->num_of_keys; i++, j++) {
        if (j == insertion_index) j++;
        temp[j] = ol->records[i];
    }
    // 비워둔 칸에 insert할 record 넣기
    temp[insertion_index] = inst;
    ol->num_of_keys = 0;
    split = cut(LEAF_MAX); // 작수면 /2, 홀수면 /2 + 1

    // old leaf, new leaf 에 나눠서 넣음
    for (i = 0; i < split; i++) {
        ol->records[i] = temp[i];
        ol->num_of_keys++;
    }

    for (i = split, j = 0; i < LEAF_MAX + 1; i++, j++) {
        nl->records[j] = temp[i];
        nl->num_of_keys++;
    }

    free(temp);

    //
    nl->next_offset = ol->next_offset;
    ol->next_offset = new_leaf;

    // 나머지 값 0 으로
    for (i = ol->num_of_keys; i < LEAF_MAX; i++) {
        ol->records[i].key = 0;
        //strcpy(ol->records[i].value, NULL);
    }

    for (i = nl->num_of_keys; i < LEAF_MAX; i++) {
        nl->records[i].key = 0;
        //strcpy(nl->records[i].value, NULL);
    }

    // 부모 페이지 설정
    nl->parent_page_offset = ol->parent_page_offset;
    new_key = nl->records[0].key;

    pwrite(fd, nl, sizeof(page), new_leaf);
    pwrite(fd, ol, sizeof(page), leaf);
    free(ol);
    free(nl);
    printf("split_leaf is complete\n");

    // new leaf 의 첫번째 key 부모 페이지에 추가
    return insert_into_parent(leaf, new_key, new_leaf);

}

off_t insert_into_parent(off_t old, int64_t key, off_t newp) {

    int left_index;
    off_t bumo;
    page * left;
    left = load_page(old);

    bumo = left->parent_page_offset;
    free(left);

    if (bumo == 0)
        // old leaf 의 부모가 없다~? -> 루트 생성
        return insert_into_new_root(old, key, newp);

    // 왼족 leaf 인 old leaf 의 부모에서의 index 반환
    left_index = get_left_index(old);

    page * parent = load_page(bumo);
    //printf("\nbumo is %ld\n", bumo);
    if (parent->num_of_keys < INTERNAL_MAX) {
        free(parent);
        // 자리 있으면 넣고
        return insert_into_internal(bumo, left_index, key, newp);
    }
    free(parent);
    // 아니면 split
    return insert_into_internal_as(bumo, left_index, key, newp);
}

int get_left_index(off_t left) {
    page * child = load_page(left);
    // left 로드하고 left의 부모 소환
    off_t po = child->parent_page_offset;
    free(child);
    page * parent = load_page(po);
    int i = 0;
    if (left == parent->next_offset) return -1;
    // left 의 index 찾기
    for (; i < parent->num_of_keys; i++) {
        if (parent->b_f[i].p_offset == left) break;
    }

    if (i == parent->num_of_keys) {
        free(parent);
        return -10;
    }
    free(parent);
    return i;
}

off_t insert_into_new_root(off_t old, int64_t key, off_t newp) {
    // 새로운 루트노드 생성
    printf("new node ! \n"); // todo
    off_t new_root;
    new_root = new_page();
    page * nr = load_page(new_root);
    nr->b_f[0].key = key;
    nr->next_offset = old;
    nr->b_f[0].p_offset = newp;
    nr->num_of_keys++;

    // 루트노드의 left, right 불러와서 그들의 parent 설정해주고 저장
    page * left = load_page(old);
    page * right = load_page(newp);
    left->parent_page_offset = new_root;
    right->parent_page_offset = new_root;
    pwrite(fd, nr, sizeof(page), new_root);
    pwrite(fd, left, sizeof(page), old);
    pwrite(fd, right, sizeof(page), newp);
    free(nr);

    nr = load_page(new_root);
    rt = nr; // 루트를 변경하고 저장
    hp->rpo = new_root;
    pwrite(fd, hp, sizeof(H_P), 0);
    free(hp);
    hp = load_header(0);
    free(left);
    free(right);
    return new_root;

}

off_t insert_into_internal(off_t bumo, int left_index, int64_t key, off_t newp) {

    page * parent = load_page(bumo);
    int i;
    // 부모 노드에서 들어갈 인덱스 찾기
    for (i = parent->num_of_keys; i > left_index + 1; i--) {
        parent->b_f[i] = parent->b_f[i - 1];
    }
    // 해당 인덱스에 값 넣고 write
    parent->b_f[left_index + 1].key = key;
    parent->b_f[left_index + 1].p_offset = newp;
    parent->num_of_keys++;

    if(bumo != hp->rpo) {
        if(parent->num_of_keys == INTERNAL_MAX) {
            // 삽입이 일어난 페이지의 노드 수가 맥스와 같을때
            int neighbor_index, k_prime_index;
            off_t neighbor_offset, grand_parent_offset;
            int64_t k_prime;
            grand_parent_offset = parent->parent_page_offset;
            page * grand_parent = load_page(grand_parent_offset);

            if (grand_parent->next_offset == bumo) {
                // 지워진 페이지가 children 중에서 첫번쩨 페이지 일떼?
                neighbor_index = -2;
                // 이웃은 두번째 child
                neighbor_offset = grand_parent->b_f[0].p_offset;
                // 두번째 child의 첫번째 key
                k_prime = grand_parent->b_f[0].key;
                k_prime_index = 0;
            }
            else if(grand_parent->b_f[0].p_offset == bumo) {
                // 지워진 페이지가 children 중에서 두번째 페이지 일떼?
                neighbor_index = -1;
                // 이웃 노드는 첫번재 노드
                neighbor_offset = grand_parent->next_offset;
                k_prime_index = 0;
                k_prime = grand_parent->b_f[0].key;
            }
            else {
                // 나머지
                int i;
                // 지워진 페이지에 대한 인덱스 찾기
                for (i = 0; i <= grand_parent->num_of_keys; i++)
                    if (grand_parent->b_f[i].p_offset == bumo) break;
                // 지워진 노드의 왼쪽이 이웃 노드
                neighbor_index = i - 1;
                neighbor_offset = grand_parent->b_f[i - 1].p_offset;
                k_prime_index = i;
                k_prime = grand_parent->b_f[i].key;
            }

            // 이웃 노드 불러옴
            page * neighbor = load_page(neighbor_offset);
            if(neighbor->num_of_keys < INTERNAL_MAX) {
                free(neighbor);
                free(grand_parent);
                redistribution_pages_insert(bumo,neighbor_index,neighbor_offset,grand_parent_offset,k_prime,k_prime_index);
            }
        }
    }

    pwrite(fd, parent, sizeof(page), bumo);
    free(parent);

    if (bumo == hp->rpo) {
        free(rt);
        rt = load_page(bumo);
        // 변경한 부모가 루트라면 루트를 다시 로드 한다.
    }
    return hp->rpo;
}

off_t insert_into_internal_as(off_t bumo, int left_index, int64_t key, off_t newp) {

    int i, j, split;
    int64_t k_prime;
    off_t new_p, child;
    I_R * temp;

    temp = (I_R *)calloc(INTERNAL_MAX + 1, sizeof(I_R));

    page * old_parent = load_page(bumo);

    // 인덱스에 해당하는 부분을 건너 뛰고 부모 노드의 정보 백업 + 빈 칸에 insert key 넣기
    for (i = 0, j = 0; i < old_parent->num_of_keys; i++, j++) {
        if (j == left_index + 1) j++;
        temp[j] = old_parent->b_f[i];
    }

    temp[left_index + 1].key = key;
    temp[left_index + 1].p_offset = newp;

    split = cut(INTERNAL_MAX);
    new_p = new_page();
    page * new_parent = load_page(new_p);
    // 새로운 페이지 로드
    old_parent->num_of_keys = 0;
    // Old parent 에 절반의 정보 삽입
    for (i = 0; i < split; i++) {
        old_parent->b_f[i] = temp[i];
        old_parent->num_of_keys++;
    }
    // 가운데 키는 따로 빼고
    k_prime = temp[i].key;
    new_parent->next_offset = temp[i].p_offset;
    // new parent 에 나머지 절반 삽입
    for (++i, j = 0; i < INTERNAL_MAX + 1; i++, j++) {
        new_parent->b_f[j] = temp[i];
        new_parent->num_of_keys++;
    }

    new_parent->parent_page_offset = old_parent->parent_page_offset;
    page * nn;
    nn = load_page(new_parent->next_offset);
    nn->parent_page_offset = new_p;
    pwrite(fd, nn, sizeof(page), new_parent->next_offset);
    free(nn);
    for (i = 0; i < new_parent->num_of_keys; i++) {
        child = new_parent->b_f[i].p_offset;
        page * ch = load_page(child);
        ch->parent_page_offset = new_p;
        pwrite(fd, ch, sizeof(page), child);
        free(ch);
    }

    pwrite(fd, old_parent, sizeof(page), bumo);
    pwrite(fd, new_parent, sizeof(page), new_p);
    free(old_parent);
    free(new_parent);
    free(temp);
    // 쪼개고 중간 키 부모에 다시 삽입
    return insert_into_parent(bumo, k_prime, new_p);
}

int db_delete(int64_t key) {

    // 데이터 베이스가 비어있거나, 지우려는 키가 존재하지 않는 경우 조사
    if (rt->num_of_keys == 0) {
        //printf("root is empty\n");
        return -1;
    }
    char * check = db_find(key);
    if (check== NULL) {
        free(check);
        //printf("There are no key to delete\n");
        return -1;
    }
    free(check);
    // 해당 키를 지우기 위해 리프의 오프셋 찾기
    off_t deloff = find_leaf(key);
    // delete
    delete_entry(key, deloff);
    return 0;

}//fin

void delete_entry(int64_t key, off_t deloff) {

    // 해당 키 제거
    remove_entry_from_page(key, deloff);

    // 변경된 노드가 루트라면?
    if (deloff == hp->rpo) {
        adjust_root(deloff);
        return;
    }

    // 삭제된 페이지의 남아있는 노드의 수가 1/4 이상일땐 그냥 끝
    page * not_enough = load_page(deloff);
    int check = not_enough->is_leaf ? cut(cut(LEAF_MAX)) : cut(cut(INTERNAL_MAX));
    if (not_enough->num_of_keys > check){
      free(not_enough);
      //printf("just delete\n");
      return;  
    }

    // 남아 있는 노드의 수가 절반 이하일 때
    int neighbor_index, k_prime_index;
    off_t neighbor_offset, parent_offset;
    int64_t k_prime;
    parent_offset = not_enough->parent_page_offset;
    page * parent = load_page(parent_offset);

    if (parent->next_offset == deloff) {
        // 지워진 페이지가 children 중에서 첫번쩨 페이지 일떼?
        neighbor_index = -2;
        // 이웃은 두번째 child
        neighbor_offset = parent->b_f[0].p_offset;
        // 두번째 child의 첫번째 key
        k_prime = parent->b_f[0].key;
        k_prime_index = 0;
    }
    else if(parent->b_f[0].p_offset == deloff) {
        // 지워진 페이지가 children 중에서 두번째 페이지 일떼?
        neighbor_index = -1;
        // 이웃 노드는 첫번재 노드
        neighbor_offset = parent->next_offset;
        k_prime_index = 0;
        k_prime = parent->b_f[0].key;
    }
    else {
        // 나머지
        int i;
        // 지워진 페이지에 대한 인덱스 찾기
        for (i = 0; i <= parent->num_of_keys; i++)
            if (parent->b_f[i].p_offset == deloff) break;
        // 지워진 노드의 왼쪽이 이웃 노드
        neighbor_index = i - 1;
        neighbor_offset = parent->b_f[i - 1].p_offset;
        k_prime_index = i;
        k_prime = parent->b_f[i].key;
    }

    // 이웃 노드 불러옴
    page * neighbor = load_page(neighbor_offset);
    int max = not_enough->is_leaf ? LEAF_MAX : INTERNAL_MAX - 1;
    int why = neighbor->num_of_keys + not_enough->num_of_keys;

    if (why <= cut(max)) {
        // (이웃의 키 + 지운 노드의 키) <= max/2
        free(not_enough);
        free(parent);
        free(neighbor);
        coalesce_pages(deloff, neighbor_index, neighbor_offset, parent_offset, k_prime);
    }
    else if (neighbor->num_of_keys > not_enough->num_of_keys) {
        // (이웃의 키 + 지운 노드의 키) > max
        // 이웃의 키가 나보다 많을 때에만 재분배 일어남
        free(not_enough);
        free(parent);
        free(neighbor);
        redistribute_pages(deloff, neighbor_index, neighbor_offset, parent_offset, k_prime, k_prime_index);
    } else {
        free(not_enough);
        free(parent);
        free(neighbor);
    }

    return;

}

void redistribute_pages(off_t need_more, int nbor_index, off_t nbor_off, off_t par_off, int64_t k_prime, int k_prime_index) {
    // 이웃에게서 빌려오기
    page *need, *nbor, *parent;
    int i;
    need = load_page(need_more);
    nbor = load_page(nbor_off);
    parent = load_page(par_off);
    if (nbor_index != -2) {
        // 맨 왼쪽 아닐때
        if (!need->is_leaf) {
            // 리프가 아님
            // need 한칸씩 밀어버림
            for (i = need->num_of_keys; i > 0; i--)
                need->b_f[i] = need->b_f[i - 1];

            // need에 prime 넣음
            need->b_f[0].key = k_prime;
            // 새로 들어온 키가 가리키는 값을 이웃의 제일 오른쪽이 가리키던 값으로 바꾼다
            need->b_f[0].p_offset = need->next_offset;
            need->next_offset = nbor->b_f[nbor->num_of_keys - 1].p_offset;
            page * child = load_page(need->next_offset);
            child->parent_page_offset = need_more;
            pwrite(fd, child, sizeof(page), need->next_offset);
            free(child);
            parent->b_f[k_prime_index].key = nbor->b_f[nbor->num_of_keys - 1].key;
            
        }
        else {
            //printf("redis average leaf\n");
            for (i = need->num_of_keys; i > 0; i--){
                need->records[i] = need->records[i - 1];
            }
            need->records[0] = nbor->records[nbor->num_of_keys - 1];
            nbor->records[nbor->num_of_keys - 1].key = 0;
            parent->b_f[k_prime_index].key = need->records[0].key;
        }

    }
    else {
        //
        if (need->is_leaf) {
            //printf("redis leftmost leaf\n");
            need->records[need->num_of_keys] = nbor->records[0];
            for (i = 0; i < nbor->num_of_keys - 1; i++)
                nbor->records[i] = nbor->records[i + 1];
            parent->b_f[k_prime_index].key = nbor->records[0].key;
            
           
        }
        else {
            // 맨 왼쪽인데 리프 아님
            // 오른쪽에 있는걸 하나 빌려와야함
            // 내꺼 맨 끝에 일단 추가해버림
            need->b_f[need->num_of_keys].key = k_prime;
            need->b_f[need->num_of_keys].p_offset = nbor->next_offset;
            // 그거 불러와서 부모도 수정
            page * child = load_page(need->b_f[need->num_of_keys].p_offset);
            child->parent_page_offset = need_more;
            pwrite(fd, child, sizeof(page), need->b_f[need->num_of_keys].p_offset);
            free(child);
            
            parent->b_f[k_prime_index].key = nbor->b_f[0].key;
            nbor->next_offset = nbor->b_f[0].p_offset;
            for (i = 0; i < nbor->num_of_keys - 1 ; i++)
                nbor->b_f[i] = nbor->b_f[i + 1];
            
        }
    }
    nbor->num_of_keys--;
    need->num_of_keys++;
    pwrite(fd, parent, sizeof(page), par_off);
    pwrite(fd, nbor, sizeof(page), nbor_off);
    pwrite(fd, need, sizeof(page), need_more);
    free(parent); free(nbor); free(need);
    return;
}

void coalesce_pages(off_t will_be_coal, int nbor_index, off_t nbor_off, off_t par_off, int64_t k_prime) {
    // merge 를 해야하는 상황
    page *wbc, *nbor, *parent;
    off_t newp, wbf;

    if (nbor_index == -2) {
        // 제일 왼쪽 일 때
        wbc = load_page(nbor_off); nbor = load_page(will_be_coal); parent = load_page(par_off);
        newp = will_be_coal; wbf = nbor_off;
    }
    else {
        // 나머지 경우
        wbc = load_page(will_be_coal); nbor = load_page(nbor_off); parent = load_page(par_off);
        newp = nbor_off; wbf = will_be_coal;
    }

    int point = nbor->num_of_keys;
    int le = wbc->num_of_keys;
    int i, j;
    if (!wbc->is_leaf) {
        // 리프가 아니라면
        // nbor에 k_prime 값 넣기
        nbor->b_f[point].key = k_prime;
        nbor->b_f[point].p_offset = wbc->next_offset;
        nbor->num_of_keys++;

        // 그 다음에는 wbc에 있는 key를 nbor에 옮기기
        for (i = point + 1, j = 0; j < le; i++, j++) {
            nbor->b_f[i] = wbc->b_f[j];
            nbor->num_of_keys++;
            wbc->num_of_keys--;
        }

        // 걔네들 + prime 의 부모를 새로운 노드(nbor)로 수정 (merge 니까 부모 수정해줘야함)
        for (i = point; i < nbor->num_of_keys; i++) {
            page * child = load_page(nbor->b_f[i].p_offset);
            child->parent_page_offset = newp;
            pwrite(fd, child, sizeof(page), nbor->b_f[i].p_offset);
            free(child);
        }

    }
    else {
        // 리프일때
        int range = wbc->num_of_keys;
        for (i = point, j = 0; j < range; i++, j++) {
            nbor->records[i] = wbc->records[j];
            nbor->num_of_keys++;
            wbc->num_of_keys--;
        }
        nbor->next_offset = wbc->next_offset;
    }
    pwrite(fd, nbor, sizeof(page), newp);
    
    delete_entry(k_prime, par_off);
    free(wbc);
    usetofree(wbf);
    free(nbor);
    free(parent);
    return;

}//fin

void adjust_root(off_t deloff) {

    if (rt->num_of_keys > 0)
        return;
    if (!rt->is_leaf) {
        // 지웠는데 루트의 데이터가 0 개임
        // 루트가 리프가 아님
        // 다음 노드를 새로운 루트로 지정하고 저장
        off_t nr = rt->next_offset;
        page * nroot = load_page(nr);
        nroot->parent_page_offset = 0;
        usetofree(hp->rpo);
        hp->rpo = nr;
        pwrite(fd, hp, sizeof(H_P), 0);
        free(hp);
        hp = load_header(0);
        
        pwrite(fd, nroot, sizeof(page), nr);
        free(nroot);
        free(rt);
        rt = load_page(nr);

        return;
    }
    else {
        // 루트면? 처음 무의 상태로
        free(rt);
        rt = NULL;
        usetofree(hp->rpo);
        hp->rpo = 0;
        pwrite(fd, hp, sizeof(hp), 0);
        free(hp);
        hp = load_header(0);
        return;
    }
}//fin

void remove_entry_from_page(int64_t key, off_t deloff) {
    
    int i = 0;
    page * lp = load_page(deloff);
    // leaf 라면
    if (lp->is_leaf) {
        // 해당 키에 대한 인덱스 찾기
        while (lp->records[i].key != key)
            i++;

        // 배열 내에서 지우고
        for (++i; i < lp->num_of_keys; i++)
            lp->records[i - 1] = lp->records[i];
        lp->num_of_keys--;
        // 변경사항 write
        pwrite(fd, lp, sizeof(page), deloff);
        // 변경된 노드가 루트라면?
        if (deloff == hp->rpo) {
            // 루트 다시 로드
            free(lp);
            free(rt);
            rt = load_page(deloff);
            return;
        }
        
        free(lp);
        return;
    }
    else {
        // leaf 가 아니라면
        // 해당 키에 대한 인덱스 찾고
        while (lp->b_f[i].key != key)
            i++;
        // 해당 키 삭제하고 write
        for (++i; i < lp->num_of_keys; i++)
            lp->b_f[i - 1] = lp->b_f[i];
        lp->num_of_keys--;
        pwrite(fd, lp, sizeof(page), deloff);
        // 해당 노드가 루트라면
        if (deloff == hp->rpo) {
            // 루트 다시 로드
            free(lp);
            free(rt);
            rt = load_page(deloff);
            return;
        }
        
        free(lp);
        return;
    }
    
}//fin






