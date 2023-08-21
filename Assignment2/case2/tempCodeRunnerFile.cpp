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