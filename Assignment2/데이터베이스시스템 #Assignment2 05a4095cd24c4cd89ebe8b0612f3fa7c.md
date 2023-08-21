# 데이터베이스시스템 #Assignment2

# Case1

## Problem

Table1 (name, age) - name 기준 정렬

Table2 (name, salary) - name 기준 정렬

name을 기준으로 natural join 수행 (name, age, salary)

## JOIN Algorithm : Merge

양쪽의 사이즈가 같아  merge join을 했을 때 시간에 대한 손실이 거의 발생하지 않는다. 또한 정렬이 이미 되어있기 때문에 정렬에 대한 부담이 없다. 이 때문에 merger join를 사용하는것이 매우 좋다고 생각하여 Merge join를 사용하게 되었다. 정렬을 따로 할 필요가 없고 두개의 테이블을 위에서 아래로 선형적으로 한번 내려오면 조인이 끝난다. 

## Code

아우터블럭 하나 이너블럭 하나씩 읽어 이름이 깉으면 양쪽의 인덱스를 하나씩 내려가게 하였다. (이름을 통해 join을 하는것인데 이름이 유니크하다는 조건이 있어 같은 이름이 있는 경우는 고려하지 않음) 만약 해당 블럭을 다 읽었으면 다음 블럭을 읽게 된다.  

```cpp
current_block[0] = 0; // outer index
    current_block[1] = 0; // inner index

    
    int inner_column_index = 0;
    int outer_column_index = 0;

    block[0].open("./name_age/"+to_string(current_block[0]) + ".csv");
    block[1].open("./name_salary/"+to_string(current_block[1]) + ".csv");

    getline(block[0],temp0.name,','); // outer 에서 이름
    getline(block[1],temp1.name,','); // inner 에서 이름

    while (true) {
        if(temp0.name == temp1.name) {
            // 이름이 같은 상황
            output << temp0.name << ",";
            getline(block[0],temp0.age,'\n'); // outer 에서 나이
            getline(block[1],temp1.salary,'\n'); // inner 에서 연봉
            output << temp0.age << "," << temp1.salary << "\n"; // 이름,나이,연봉 을 아웃풋 파일에 쓰기

            inner_column_index++;
            outer_column_index++;

            if(outer_column_index < 10) {
                getline(block[0],temp0.name,','); // outer 에서 이름 update
            }
            if(inner_column_index < 10) {
                getline(block[1],temp1.name,','); // inner 에서 이름 update
            }
        } else {
            // 이름이 다른 상황
            if(temp0.name > temp1.name) {
                // outer의 이름이 사전순으로 더 뒤에있음
                // inner의 인덱스를 증가시킴
                inner_column_index++;
                if(inner_column_index < 10) {
                    getline(block[1],buffer[1],'\n'); // 불렀던 salary 버리기 
                    getline(block[1],temp1.name,','); // inner 에서 이름 update
                }

            } else {
                // inner의 이름이 사전순으로 더 뒤에있음
                // outer의 인덱스를 증가시킴
                int trash;
                outer_column_index++;
                if(outer_column_index < 10) {
                    getline(block[0],buffer[0],'\n'); // 불렀던 나이 버리기 
                    getline(block[0],temp0.name,','); // outer 에서 이름 update
                }
            }
        }

        if(outer_column_index == 10) {
            // 끝까지 읽음 -> 다음 파일 오픈
            if(current_block[0]<999) {
                current_block[0]++;
                block[0].close();
                block[0].open("./name_age/"+to_string(current_block[0]) + ".csv");
                outer_column_index = 0;
                getline(block[0],temp0.name,','); // outer 에서 이름 update
            } else {
                break; // outer의 모든 블럭을 다 읽은것 이므로 break
            }
        }

        if(inner_column_index == 10) {
            // 끝까지 읽음 -> 다음 파일 오픈
            if(current_block[1]<999) {
                current_block[1]++;
                block[1].close();
                block[1].open("./name_salary/"+to_string(current_block[1]) + ".csv");
                inner_column_index = 0;
                getline(block[1],temp1.name,','); // outer 에서 이름 update
            } else {
                break; // inner의 모든 블럭을 다 읽은것 이므로 break
            }
        }
    }
```

## Result

![Untitled](%E1%84%83%E1%85%A6%E1%84%8B%E1%85%B5%E1%84%90%E1%85%A5%E1%84%87%E1%85%A6%E1%84%8B%E1%85%B5%E1%84%89%E1%85%B3%E1%84%89%E1%85%B5%E1%84%89%E1%85%B3%E1%84%90%E1%85%A6%E1%86%B7%20#Assignment2%2005a4095cd24c4cd89ebe8b0612f3fa7c/Untitled.png)

![Untitled](%E1%84%83%E1%85%A6%E1%84%8B%E1%85%B5%E1%84%90%E1%85%A5%E1%84%87%E1%85%A6%E1%84%8B%E1%85%B5%E1%84%89%E1%85%B3%E1%84%89%E1%85%B5%E1%84%89%E1%85%B3%E1%84%90%E1%85%A6%E1%86%B7%20#Assignment2%2005a4095cd24c4cd89ebe8b0612f3fa7c/Untitled%201.png)

# Case2

## Problem

Table1 (name, age) - age 기준 정렬

Table2 (name, salary) - salary 기준 정렬

name을 기준으로 natural join 수행 (name, age, salary)

## JOIN Algorithm : Hash

이름으로 join하기 때문에 각각 나이와 연봉으로 정렬되어있는건 무작위나 마찬가지이다. 그렇기에 이름순으로 정렬하여 조인하는 머지소트조인를 사용하기엔 정렬하는 것에 대한 오버헤드가 크다. 중첩 조인을 쓰기에는조인을 하는 두 테이블의 크기가 같기 때문에 적합하지 않다. 이렇기에 해시 함수를 이용해 조인하는 해시 조인을 사용하게 되었다. 

## Code

- 해시값을 만드는 함수

```
int make_hash(string name) {
	const char* str = name.c_str();

	int hash = 401;
	int c;
	int max_table = 11;

	while(*str != '\0') {
		hash = ((hash<<4)+(int)(*str)%max_table);
		str++;
	}

	return hash%max_table;
}
```

- 메인 알고리즘

```cpp
int outer_block = 0; // 아우터 블럭의 인덱스
	int inner_block = 0; // 이너 블럭의 인덱스

	// 해시 테이블을 담을 버켓을 열어준다.
	for(int i=0 ; i<11 ; i++) {
		block[i].open("../buckets/test2_outer_"+to_string(i) + ".csv", ios::out); // 파일을 쓰기때문에 ios::out 써주기
	}

	while(outer_block<1000) {
		// 모든 아우터 블럭에 대해서 0부터 999 까지 파일을 연다
		block[11].open("./name_age/"+to_string(outer_block) + ".csv");
		for(int i=0 ; i<10 ; i++) {
			// 열어서 안에 있는 요소에 대해 이름값으로 해시값을 구한 다음에 그 해시값에 해당하는 버켓에 담는다.
			getline(block[11],buffer[0],'\n');
			temp0.set_name_age(buffer[0]);
			int hash_result = make_hash(temp0.name);

			block[hash_result] << temp0.name << "," << temp0.age << "\n";
		}
		// 블럭 안의 값을 다 읽었다면 다음 블럭으로
		block[11].close();
		outer_block++;
	}

	// 버켓을 위해 열었던 스트림 닫기
	for(int i=0 ; i<11 ; i++) {
		block[i].close();
	}

	// 이너 블럭의 버켓을 위한 스트림 열기
	for(int i=0 ; i<11 ; i++) {
		block[i].open("../buckets/test2_inner_"+to_string(i) + ".csv", ios::out);
	}

	while(inner_block<1000) {
		// 모든 이너 블럭에 대해 0부터 999 까지 열어본다. 
		block[11].open("./name_salary/"+to_string(inner_block) + ".csv");
		for(int i=0 ; i<10 ; i++) {
			// 각 블럭의 요소를 살펴보며 이름에 대한 해시값을 구하고 해당 해시값에 해당하는 버켓에 값을 넣는다.
			getline(block[11],buffer[1],'\n');
			temp1.set_name_salary(buffer[1]);
			int hash_result = make_hash(temp1.name);

			block[hash_result] << temp1.name << "," << temp1.salary << "\n";
		}
		// 해당 블럭을 다 읽었다면 다음 블럭으로
		block[11].close();
		inner_block++;
	}
	for(int i=0 ; i<11 ; i++) {
		block[i].close(); // 버켓을 열었던 스트림 닫기
	}

	for(int i=0 ; i<11 ; i++) {
		// 두 버킷을 연다 아우터의버킷i번 이너의버킷i번
		block[0].open("../buckets/test2_outer_"+to_string(i) + ".csv");
		block[1].open("../buckets/test2_inner_"+to_string(i) + ".csv");

		while(getline(block[0],buffer[0],'\n')) {
			// 버킷을 순회하며 이름이 같다면 결과 값에 추가한다. 
			temp0.set_name_age(buffer[0]);
			while(getline(block[1],buffer[1],'\n')) {
				temp1.set_name_salary(buffer[1]);
				if(temp0.name == temp1.name) {
					output << make_tuple(temp0.name,temp0.age,temp1.salary);
					break;
				}
			}
			block[1].seekg(0,ios::beg);
		}

		block[0].close();
		block[1].close();
	}
```

## Result

![Untitled](%E1%84%83%E1%85%A6%E1%84%8B%E1%85%B5%E1%84%90%E1%85%A5%E1%84%87%E1%85%A6%E1%84%8B%E1%85%B5%E1%84%89%E1%85%B3%E1%84%89%E1%85%B5%E1%84%89%E1%85%B3%E1%84%90%E1%85%A6%E1%86%B7%20#Assignment2%2005a4095cd24c4cd89ebe8b0612f3fa7c/Untitled%202.png)

# Case3

## 주어진 상황

Table1 (student_name, korean, math, english, science, social, history) - 이름/1학기 성적, 무작위 배열

Table2 (student_name, korean, math, english, science, social, history) - 이름/2학기 성적, 무작위 배열

Table3 (student_name, student_number) - 무작위 배열

각 과목에 대해 1학기에 비해 2학기 때 성적 향상이 일어난 과목의 개수가 2개 이상인 학생의 이름과 학번 (student_name, student_number)

## JOIN Algorithm : Block Nested-Loop & Hash

먼저 이 상황에서 테이블이 3개라 조인을 두번해야하는데 먼저 상승한 과목수가 2개인 사람들을 찾아 최대한 테이블의 크기를 줄였다. 첫번째 조인은 Case2와 상황이 같으므로 해시 조인을 사용하였다. 이때 버켓에 들어가는 기준에 두과목 이상 상승한 사람만 넣어 최종적으로 버켓에는 두 과목 이상 상승한 사람들만 넣는다. 그리고 해당 조인 결과를 따로 저장한 뒤 두번째로 조인하는것은 이미 한쪽 테이블의 크기가 줄어든 상황이기 때문에 작은 테이블을 이너 테이블러 설정하고 중첩 조인을 실행한다. 

## Code

- 해시 함수

```cpp
int make_hash(string name) {
	const char* str = name.c_str();

	int hash = 401;
	int c;
	int max_table = 11;

	while(*str != '\0') {
		hash = ((hash<<4)+(int)(*str)%max_table);
		str++;
	}

	return hash%max_table;
}
```

- 상승한 과목이 3개가 넘는지 카운트 해주는 함수

```cpp
bool over_2_sub(name_grade first, name_grade second) {
	int count = 0;
	if(first.korean < second.korean ) {
		count ++;
	}
	if(first.math < second.math ) {
	count ++;
	}
	if(first.english < second.english ) {
		count ++;
	}
	if(first.science < second.science ) {
		count ++;
	}
	if(first.social < second.social ) {
		count ++;
	}
	if(first.history < second.history ) {
		count ++;
	}

	return count>=2;
}
```

- 메인 알고리즘

```cpp
int outer_block = 0; // 아우터 블럭의 인덱스
	int inner_block = 0; // 이너 블럭의 인덱스

	// 버켓을 위한 스트림을 연다. 
	for(int i=0 ; i<11 ; i++) {
		block[i].open("../buckets/test3_outer_"+to_string(i) + ".csv", ios::out); // 쓰는것이라 아웃 인자로 보냄
	}

	while(outer_block<1000) {
		// 아우터 블럭의 모든 값에 대해서 0부터 999 까지 열기
		block[11].open("./name_grade1/"+to_string(outer_block) + ".csv");
		for(int i=0 ; i<10 ; i++) {
			// 블럭 안의 요소의 이름을 통해 해시값을 구해서 해당 해시값에 해단하는 버켓에 값을 저장한다.
			getline(block[11],buffer[0],'\n');
			temp0.set_grade(buffer[0]);
			int hash_result = make_hash(temp0.student_name);

			block[hash_result] << buffer[0] << "\n";
		}
		// 블럭 다 읽었으면 닫고 다음 블럭으로
		block[11].clear();
		block[11].close();
		outer_block++;
	}

	// 버켓을 위해 열었던 스트림 닫기
	for(int i=0 ; i<11 ; i++) {
		block[i].clear();
		block[i].close();
	}

	// 이너블럭 값을 담을 버켓을 위한 스트림 열기
	for(int i=0 ; i<11 ; i++) {
		block[i].open("../buckets/test3_inner_"+to_string(i) + ".csv", ios::out);
	}

	// 모든 이너 블럭에 대해
	while(inner_block<1000) {
		block[11].open("./name_grade2/"+to_string(inner_block) + ".csv");
		for(int i=0 ; i<10 ; i++) {
			// 해당 값의 이름을 통해 해시값을 얻고 해시값에 해당하는 버켓에 값을 넣는다.
			getline(block[11],buffer[1],'\n');
			temp1.set_grade(buffer[1]);
			int hash_result = make_hash(temp1.student_name);

			block[hash_result] << buffer[1] << "\n";
		}
		// 다 읽었으면 닫고 다음 블럭으로
		block[11].clear();
		block[11].close();
		inner_block++;
	}
	// 열었던 버킷 닫기
	for(int i=0 ; i<11 ; i++) {
		block[i].clear();
		block[i].close();
	}

	// 먼저 조인 한 값을 저장하기 위한 파일 생성
	block[2].open("../buckets/hashjoin_result.csv",ios::out);
	for(int i=0 ; i<11 ; i++) {
		// 각각에 해당하는 버킷 열기 ( 같은 인덱스에 있는 )
		block[0].open("../buckets/test3_outer_"+to_string(i) + ".csv");
		block[1].open("../buckets/test3_inner_"+to_string(i) + ".csv");

		while(getline(block[0],buffer[0],'\n')) {
			// 버켓들의 값들을 순회하며 이름이 같고 점수가 상승한 과목이 2개 이상인 사람의 이름을 결과 파일에 저장한다. 
			temp0.set_grade(buffer[0]);
			while(getline(block[1],buffer[1],'\n')) {
				temp1.set_grade(buffer[1]);
				
				if(temp0.student_name == temp1.student_name) {
					if(over_2_sub(temp0,temp1)) {
						block[2] << temp0.student_name << "\n";
					}
					break;
				}
			}
			// 또 돌아야 하기 때문에 포인터를 맨 앞으로 옮겨준다.
			block[1].clear();
			block[1].seekg(0,ios::beg);
		}
		// 버켓들 다 돌았으면 닫기
		block[0].clear();
		block[1].clear();

		block[0].close();
		block[1].close();
	}
	block[2].clear();
	block[2].close();

	outer_block = 0;
	inner_block = 0;

	// 값을 읽을 버켓 불러오기
	block[1].open("../buckets/hashjoin_result.csv", ios::in);
	while(outer_block<1000) {
		// 학번이 담긴 아우터 블럭 모두 부르기
		block[0].open("./name_number/" + to_string(outer_block) + ".csv", ios::in);
		
		while (getline(block[0],buffer[0],'\n'))
		{
			// 아우터 블럭들 중 연 블럭 전체와 버킷 전체를 비교하며 이름이 같으면 이름 + 학번 값을 결과에 저장한다. 
			temp2.set_number(buffer[0]);
			
			while(getline(block[1],buffer[1])) {
				
				if(temp2.student_name == buffer[1]) {
					output << buffer[0] << "\n";
					break;
				} 
			}
			// 다시 돌아야 하므로 처음으로 돌아가기
			block[1].clear();
			block[1].seekg(0,ios::beg);
		}
		
		block[0].clear();
		
		block[0].close();
		outer_block++;
	}

	block[1].close();
```

## Result

![Untitled](%E1%84%83%E1%85%A6%E1%84%8B%E1%85%B5%E1%84%90%E1%85%A5%E1%84%87%E1%85%A6%E1%84%8B%E1%85%B5%E1%84%89%E1%85%B3%E1%84%89%E1%85%B5%E1%84%89%E1%85%B3%E1%84%90%E1%85%A6%E1%86%B7%20#Assignment2%2005a4095cd24c4cd89ebe8b0612f3fa7c/Untitled%203.png)

# Trobule Shooting

시간이 오래걸렸다. 조교님이 말씀해주신 시간을 기준으로는 1,2번은 1초, 3번은 3~4초 였지만 내가 짠 알고리즘은 각각 3초, 9초, 특히 3번은 40초 정도가 걸려 충격이였다.