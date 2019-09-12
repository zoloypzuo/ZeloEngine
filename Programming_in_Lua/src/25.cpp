// 不要顺序阅读整个文件的代码，从main开始，为每个test*函数加断点，直接单步调试运行看怎么回事

#include <stdio.h>
#include <string.h>
#include <stdarg.h>

extern "C" {
#include <lua/lua.h>
#include <lua/lauxlib.h>
#include <lua/lualib.h>
}


// 25.1 从lua脚本文件中读取两个全局变量
// fname是文件
// w和h是返回的两个变量
void loadWHOnly(lua_State *L, const char *fname, int *w, int *h)
{
	// 一般用luaL_dofile替代
	// 解释执行中发生错误则返回非零错误码，错误信息被压栈，因此发生错误时弹栈取出错误信息
	if (luaL_loadfile(L, fname) || lua_pcall(L, 0, 0, 0))
		printf("cannot run config. file:%s\n", lua_tostring(L, -1));

	// 按名获取全局变量，全局变量被压栈
	lua_getglobal(L, "width");
	lua_getglobal(L, "height");

	// 然后从栈中取出变量
	// 因为栈是空的，1和2处放了这两个变量，可以正索引，也可以反索引，都是合理的
	// 但是推荐反索引，能应对栈非空的情况，而且，栈本身应该先进后出，反索引更合适
	if (!lua_isnumber(L, -2))
		printf("width should be a number\n");
	if (!lua_isnumber(L, -1))
		printf("height should be a number\n");
	*w = lua_tointeger(L, -2);
	*h = lua_tointeger(L, -1);
}

/*

a.lua
width = 3
height = 4

*/
void testWHOnly(lua_State *L)
{
	int w, h;
	loadWHOnly(L, "a.lua", &w, &h);
	printf("w = %d\n", w);
	printf("h = %d\n", h);
}

// 25.2 从lua脚本文件中读取和设置表的字段
#define MAX_COLOR	255
struct ColorTable {
	char *name;
	unsigned char r, g, b;
} colortable[] = {
	{const_cast<char *>("WHITE"), MAX_COLOR, MAX_COLOR, MAX_COLOR},
	{const_cast<char *>("RED"), MAX_COLOR, 0, 0},
	{NULL, 0, 0, 0},
};

// 封装setfield
void setfield(lua_State *L, const char *index, int value)
{
	// 与getfield一样，lua_setfield是key为string的情形
	// set时，压入key，再调用setfield，table在-2处
	lua_pushnumber(L, (double)value / MAX_COLOR);
	lua_setfield(L, -2, index);
}

// 将ColorTable对象加载到lua层，作为全局变量
// ct包含变量名和rgb值，rgb值以table形式存储
void setcolor(lua_State *L, struct ColorTable *ct)
{
	// 创建一个表，设置字段，再将这个表设为一个全局变量
	// 相当于_G[ct->name] = {r = ct->r, g = ct->g, b = ct->b}
	lua_newtable(L);
	setfield(L, "r", ct->r);
	setfield(L, "g", ct->g);
	setfield(L, "b", ct->b);
	lua_setglobal(L, ct->name);
}

// 封装getfield
int getfield(lua_State *L, const char *key)
{
	int result;
	// lua_gettable用来索引任意类型的key
	// 所以先压入key，再调用gettable，-2指定了table的栈索引
	//lua_pushstring(L, key);
	//lua_gettable(L, -2);
	// 因为key是字符串是很常见的情形，lua_getfield已经封装好了这个操作
	lua_getfield(L, -1, key);
	if (!lua_isnumber(L, -1))
		printf("invalid component in color component:%s", key);
	result = lua_tonumber(L, -1)*MAX_COLOR;
	// 把value弹出，确保调用前后栈是一致的
	lua_pop(L, 1);
	return result;
}

/*
a.lua
width=3
height=4
BLUE = {r=0, g=0, b=1}
background = {r=0.3, g=0.1, b=0.2}
foreground = WHITE
testground = RED
*/
void testTable(lua_State *L)
{
	// 初始化
	int i = 0;

	// 将c层的颜色表加载到lua层，作为全局变量
	// 这时其实还没有dofile，也不需要dofile，L初始化后就可以操作全局变量了
	while (colortable[i].name != NULL)
		setcolor(L, &colortable[i++]);

	// 解释执行脚本	
	if (luaL_loadfile(L, "a.lua") || lua_pcall(L, 0, 0, 0))
		printf("cannot run config. error:%s\n", lua_tostring(L, -1));

	// 拿到forground全局变量
	lua_getglobal(L, "foreground");
	int r, g, b;

	// 如果是string，在颜色表线性查找，否则是表，代表rgb
	if (lua_isstring(L, -1))
	{
		const char *colorname = lua_tostring(L, -1);
		int i;
		for (i = 0; colortable[i].name != NULL; i++)
		{
			if (strcmp(colorname, colortable[i].name) == 0)
				break;
		}
		if (colortable[i].name == NULL)
			printf("invalid colorname:%s\n", colorname);
		else
		{
			r = colortable[i].r;
			g = colortable[i].g;
			b = colortable[i].b;
		}
	}
	else
	{
		r = getfield(L, "r");
		g = getfield(L, "g");
		b = getfield(L, "b");
	}
}

// 25.3
// c调用lua函数封装
//
// c层函数f的签名是正常的，除了多加一个L参数
// 调用协议是：取得lua函数，压入c层参数，调用，拿返回值，弹出结果
double f(lua_State *L, double x, double y)
{
	double z;

	// lua函数，这里是全局变量
	lua_getglobal(L, "f");

	// 压入参数
	lua_pushnumber(L, x);  // 第一个参数
	lua_pushnumber(L, y);  // 第二个参数

	// 调用，并错误处理
	// pcall的参数是指，c层传入2个参数，返回一个值，没有errfunc
	// 这里的nargs会先对齐一次（截断或补nil）
	// errfunc是指错误处理函数，0表示没有，否则代表这个函数的栈索引，如果需要的话，在压入函数和参数后压入errfunc
	// 这里有一小段关于错误处理函数的事情，我这次就不管了，大意是有嵌套错误的可能
	if (lua_pcall(L, 2, 1, 0) != 0)
		printf("error running function 'f':%s", lua_tostring(L, -1));

	// 拿返回值，并验证返回类型
	// 多返回值的时候，也是第一个返回值先压入，以此类推
	if (!lua_isnumber(L, -1))
		printf("function 'f' must return a number");
	z = lua_tonumber(L, -1);

	// 弹出返回值，恢复栈
	lua_pop(L, 1);

	// 从c层返回值
	return z;
}

// 25.3
// c调用lua函数测试
/*
25_3.lua

*/
void testCCallLuaFunc(lua_State *L)
{
	if (luaL_loadfile(L, "part4/25_3.lua") || lua_pcall(L, 0, 0, 0))
		printf("run func.lua error");
	int z = f(L, 3, 2);
	printf("%d\n", z);
}

// 通用的C调用lua函数
// 例如: call_va("f", "dd>d", x, y, &z)
void call_va(lua_State *L, const char *func, const char *sig, ...)
{
	va_list vl;
	int narg, nres;
	va_start(vl, sig);
	lua_getglobal(L, func);

	// 压入参数
	bool bEnd = false;
	for (narg = 0; *sig; narg++)
	{
		luaL_checkstack(L, 1, "too many arguments");
		switch (*sig++)
		{
		case 'd':
			lua_pushnumber(L, va_arg(vl, double));
			break;
		case 'i':
			lua_pushinteger(L, va_arg(vl, int));
			break;
		case 's':
			lua_pushstring(L, va_arg(vl, char*));
			break;
		case '>':
			bEnd = true;
			break;
		default:
			printf("invalid option (%c)", *(sig - 1));
		}
		if (bEnd)
			break;
	}

	nres = strlen(sig);
	if (lua_pcall(L, narg, nres, 0) != 0)
	{
		printf("error calling %s:%s", func, lua_tostring(L, -1));
	}

	// 检查结果
	nres = -nres;
	while (*sig)
	{
		switch (*sig++)
		{
		case 'd':
			if (!lua_isnumber(L, nres))
				printf("wrong result type");
			*va_arg(vl, double*) = lua_tonumber(L, nres);
			break;
		case 'i':
			if (!lua_isnumber(L, nres))
				printf("wrong result type");
			*va_arg(vl, int*) = lua_tointeger(L, nres);
			break;
		case 's':
			if (!lua_isstring(L, nres))
				printf("wrong result type");
			*va_arg(vl, const char**) = lua_tostring(L, nres);
			break;
		default:
			printf("invalid option (%c)", *(sig - 1));
		}
		nres++;
	}

	va_end(vl);
}

// 这个例子可以忽略，他试图写一个通用的调用函数，但是实践中没必要
// 而且他用字符串表示函数签名的类型，是非常不健壮的
// 而且还用了c的vararg，算了吧你
void testcall_va(lua_State *L)
{
	if (luaL_loadfile(L, "25_3.lua") || lua_pcall(L, 0, 0, 0))
		printf("run func.lua error");
	double x = 3;
	double y = 2;
	double z;
	call_va(L, "f", "dd>d", x, y, &z);
	printf("%f\n", z);
}


// main
int main()
{
	lua_State *L = luaL_newstate();
	luaL_openlibs(L);

	testWHOnly(L);		// 25.1
	testTable(L);			// 25.2
	testCCallLuaFunc(L);	// 25.3
	testcall_va(L);		// 25.4

	lua_close(L);
	return 0;
}