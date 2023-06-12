
java -jar antlr-3.2.jar  Lua.g

cd libantlr3c-3.2
make
cd ..
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib

gcc -o main main.c LuaLexer.c LuaParser.c -I /usr/local/include -L /usr/local/lib -lantlr3c

./main test/a.lua
