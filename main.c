#include "LuaLexer.h"
#include "LuaParser.h"
#include <stdio.h>

void printTree(pANTLR3_BASE_TREE tree, int depth) {
    if (tree == NULL) {
        return;
    }
    
    for (int i = 0; i < depth; i++) {
        printf("  ");
    }
    
    pANTLR3_STRING treeText = tree->getText(tree);
    printf("%s\n", treeText->chars);
    
    int childCount = tree->getChildCount(tree);
    
    for (int i = 0; i < childCount; i++) {
        printTree((pANTLR3_BASE_TREE)tree->getChild(tree, i), depth + 1);
    }
}

int main(int argc, char *argv[]) {
    if(argc != 2) {
        printf("Usage: %s <Lua file>\n", argv[0]);
        return 1;
    }

    const char *filename = argv[1];

    // Open file
    FILE *fp = fopen(filename, "r");
    if(fp == NULL) {
        printf("Failed to open file: %s\n", filename);
        return 1;
    }

    // Determine file size
    fseek(fp, 0L, SEEK_END);
    size_t filesize = ftell(fp);
    fseek(fp, 0L, SEEK_SET);

    // Read entire file into memory
    char *inputData = (char*)malloc(filesize + 1);
    fread(inputData, 1, filesize, fp);
    inputData[filesize] = 0;  // Null-terminate the input data
    fclose(fp);

    // Create input stream
    pANTLR3_INPUT_STREAM input = antlr3NewAsciiStringInPlaceStream((pANTLR3_UINT8)inputData, filesize, NULL);

    // Create the lexer
    pLuaLexer lexer = LuaLexerNew(input);

    // Create the token stream
    pANTLR3_COMMON_TOKEN_STREAM tokenStream = antlr3CommonTokenStreamSourceNew(ANTLR3_SIZE_HINT, TOKENSOURCE(lexer));

    // Create the parser
    pLuaParser parser = LuaParserNew(tokenStream);
    
    // Parse the input stream
    LuaParser_program_return r = parser->program(parser);
    //pANTLR3_BASE_TREE tree = r.tree;

    //// Print the tree
    //printTree(tree, 0);

    // Cleanup
    parser->free(parser);  
    tokenStream->free(tokenStream);
    lexer->free(lexer);    
    input->close(input);

    return 0;
}

