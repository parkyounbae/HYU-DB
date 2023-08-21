#include "bpt.h"

int main(){
    int64_t input;
    char instruction; // 명령어 저장
    char buf[120]; // 버퍼
    char *result;
    open_table("test.db"); //파일을 여는 함수 , 정의는 bpt.c에 정의되어 있음
    while(scanf("%c", &instruction) != EOF){
    // 명령어에 대한 입력을 지속적으로 받는다.
        switch(instruction){
            case 'i':
                // insert : (key:value)
                scanf("%ld %s", &input, buf);
                db_insert(input, buf);
                break;
            case 'f':
                scanf("%ld", &input);
                result = db_find(input);
                if (result) {
                    printf("Key: %ld, Value: %s\n", input, result);
                }
                else
                    printf("Not Exists\n");

                fflush(stdout);
                break;
            case 'd':
                scanf("%ld", &input);
                db_delete(input);
                break;
            case 'p':
                print_tree();
                break;
            case 'q':
                while (getchar() != (int)'\n');
                return EXIT_SUCCESS;
                break;   

        }
        while (getchar() != (int)'\n');
    }
    printf("\n");
    return 0;
}



