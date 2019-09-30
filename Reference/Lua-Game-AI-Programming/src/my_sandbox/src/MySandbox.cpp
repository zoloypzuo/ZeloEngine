#include "my_sandbox/include/MySandbox.h"

MySandbox::MySandbox() :SandboxApplication("My Sandbox"){

}

MySandbox::~MySandbox(){

}

void MySandbox::Initialize(){
	SandboxApplication::Initialize();

	// œ‡∂‘”⁄bin/x32/debug
	AddResourceLocation("../../../src/my_sandbox/script");

	CreateSandbox("Sandbox.lua");
}