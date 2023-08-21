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

int main(){

	string buffer[2];
	name_age temp0;
	name_salary temp1;
	fstream block[12];
	ofstream output;

	output.open("./output2.csv");

	if(output.fail())
	{
		cout << "output file opening fail.\n";
	}


	/******************************************************************/
	
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


	/******************************************************************/

	output.close();

	
}
