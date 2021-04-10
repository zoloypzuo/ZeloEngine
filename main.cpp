#include "ZeloPreCompiledHeader.h"
#include "Zelo.h"
#include "MyGame.h"

int main() {
    Engine engine(new MyGame());
    engine.start();
    return 0;
}