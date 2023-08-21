#include <bits/stdc++.h>
using namespace std;

class name_grade {
	public:
		string student_name;
		int korean;
		int math;
		int english;
		int science;
		int social;
		int history;

		void set_grade(string tuple)
		{
			stringstream tuplestr(tuple);
			string tempstr;

			getline(tuplestr, student_name, ',');

			getline(tuplestr, tempstr, ',');
			korean = stoi(tempstr);
			
			getline(tuplestr, tempstr, ',');
			math = stoi(tempstr);
			
			getline(tuplestr, tempstr, ',');
			english = stoi(tempstr);
			
			getline(tuplestr, tempstr, ',');
			science = stoi(tempstr);
			
			getline(tuplestr, tempstr, ',');
			social = stoi(tempstr);
			
			getline(tuplestr, tempstr);
			history = stoi(tempstr);
		}
};

class name_number{
	public :
		string student_name;
		string student_number;

		void set_number(string tuple)
		{
			stringstream tuplestr(tuple);
			string tempstr;


			getline(tuplestr, student_name, ',');
			getline(tuplestr, student_number, ',');
		}
};

string make_tuple(string name, string number)
{
	string ret = "";

	ret += name+ "," + number +"\n";

	return ret;
}

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
	name_grade temp0;
	name_grade temp1;
	name_number temp2;
	fstream block[12];
	ofstream output;

	output.open("./output3.csv");

	if(output.fail())
	{
		cout << "output file opening fail.\n";
	}

	/*********************************************************************/

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

	/*********************************************************************/

	output.close();

}
