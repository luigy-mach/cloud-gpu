#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <stdlib.h>

using namespace std;

int main() {
  ifstream in("diccionary");
  fstream out("book.txt", std::fstream::out | std::fstream::app);
  vector<string> diccionary;
  string buffer;


  while (std::getline(in, buffer)) {
    if(buffer != "")
      diccionary.push_back(buffer);
  }

  if (!out.is_open()) {
    cout << "error open file" << endl;
  }


  srand (time(NULL));
  int random, random2;
  int size = diccionary.size();
  while (1) {
    random = rand() % diccionary.size();
    random2 = rand() % 20;
    out << diccionary[random];
    if(random2 == 19) out << endl;
    else out << " ";
  }

  out.close();
}
