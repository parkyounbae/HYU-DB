#include <bits/stdc++.h>
using namespace std;

class name_age {
	public:
		string name;
		string age;
		
		void set_name_age(string tuple)
		{
			stringstream tuplestr(tuple);
			string agestr;

			getline(tuplestr, name, ',');
			getline(tuplestr, age);
		}
};

class name_salary {
	public:
		string name;
		string salary;
		
		void set_name_salary(string tuple)
		{
			stringstream tuplestr(tuple);
			string salarystr;

			getline(tuplestr, name, ',');
			getline(tuplestr, salary);
		}
};

string make_tuple(string name, string age, string salary)
{
	return name+ ',' + age + ',' + salary + '\n';
}

int main(){

	string buffer[2];
	name_age temp0;
	name_salary temp1;
	int current_block[2] = {};
	fstream block[12];
	ofstream output;

	output.open("./output1.csv");

	if(output.fail())
	{
		cout << "output file opening fail.\n";
	}

	/*********************************************************************************/

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

	/*********************************************************************************/


	output.close();
}
