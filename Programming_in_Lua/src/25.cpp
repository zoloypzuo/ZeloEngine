// ��Ҫ˳���Ķ������ļ��Ĵ��룬��main��ʼ��Ϊÿ��test*�����Ӷϵ㣬ֱ�ӵ����������п���ô����

#include <stdio.h>
#include <string.h>
#include <stdarg.h>

extern "C" {
#include <lua/lua.h>
#include <lua/lauxlib.h>
#include <lua/lualib.h>
}


// 25.1 ��lua�ű��ļ��ж�ȡ����ȫ�ֱ���
// fname���ļ�
// w��h�Ƿ��ص���������
void loadWHOnly(lua_State *L, const char *fname, int *w, int *h)
{
	// һ����luaL_dofile���
	// ����ִ���з��������򷵻ط�������룬������Ϣ��ѹջ����˷�������ʱ��ջȡ��������Ϣ
	if (luaL_loadfile(L, fname) || lua_pcall(L, 0, 0, 0))
		printf("cannot run config. file:%s\n", lua_tostring(L, -1));

	// ������ȡȫ�ֱ�����ȫ�ֱ�����ѹջ
	lua_getglobal(L, "width");
	lua_getglobal(L, "height");

	// Ȼ���ջ��ȡ������
	// ��Ϊջ�ǿյģ�1��2������������������������������Ҳ���Է����������Ǻ����
	// �����Ƽ�����������Ӧ��ջ�ǿյ���������ң�ջ����Ӧ���Ƚ������������������
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

// 25.2 ��lua�ű��ļ��ж�ȡ�����ñ���ֶ�
#define MAX_COLOR	255
struct ColorTable {
	char *name;
	unsigned char r, g, b;
} colortable[] = {
	{const_cast<char *>("WHITE"), MAX_COLOR, MAX_COLOR, MAX_COLOR},
	{const_cast<char *>("RED"), MAX_COLOR, 0, 0},
	{NULL, 0, 0, 0},
};

// ��װsetfield
void setfield(lua_State *L, const char *index, int value)
{
	// ��getfieldһ����lua_setfield��keyΪstring������
	// setʱ��ѹ��key���ٵ���setfield��table��-2��
	lua_pushnumber(L, (double)value / MAX_COLOR);
	lua_setfield(L, -2, index);
}

// ��ColorTable������ص�lua�㣬��Ϊȫ�ֱ���
// ct������������rgbֵ��rgbֵ��table��ʽ�洢
void setcolor(lua_State *L, struct ColorTable *ct)
{
	// ����һ���������ֶΣ��ٽ��������Ϊһ��ȫ�ֱ���
	// �൱��_G[ct->name] = {r = ct->r, g = ct->g, b = ct->b}
	lua_newtable(L);
	setfield(L, "r", ct->r);
	setfield(L, "g", ct->g);
	setfield(L, "b", ct->b);
	lua_setglobal(L, ct->name);
}

// ��װgetfield
int getfield(lua_State *L, const char *key)
{
	int result;
	// lua_gettable���������������͵�key
	// ������ѹ��key���ٵ���gettable��-2ָ����table��ջ����
	//lua_pushstring(L, key);
	//lua_gettable(L, -2);
	// ��Ϊkey���ַ����Ǻܳ��������Σ�lua_getfield�Ѿ���װ�����������
	lua_getfield(L, -1, key);
	if (!lua_isnumber(L, -1))
		printf("invalid component in color component:%s", key);
	result = lua_tonumber(L, -1)*MAX_COLOR;
	// ��value������ȷ������ǰ��ջ��һ�µ�
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
	// ��ʼ��
	int i = 0;

	// ��c�����ɫ����ص�lua�㣬��Ϊȫ�ֱ���
	// ��ʱ��ʵ��û��dofile��Ҳ����Ҫdofile��L��ʼ����Ϳ��Բ���ȫ�ֱ�����
	while (colortable[i].name != NULL)
		setcolor(L, &colortable[i++]);

	// ����ִ�нű�	
	if (luaL_loadfile(L, "a.lua") || lua_pcall(L, 0, 0, 0))
		printf("cannot run config. error:%s\n", lua_tostring(L, -1));

	// �õ�forgroundȫ�ֱ���
	lua_getglobal(L, "foreground");
	int r, g, b;

	// �����string������ɫ�����Բ��ң������Ǳ�����rgb
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
// c����lua������װ
//
// c�㺯��f��ǩ���������ģ����˶��һ��L����
// ����Э���ǣ�ȡ��lua������ѹ��c����������ã��÷���ֵ���������
double f(lua_State *L, double x, double y)
{
	double z;

	// lua������������ȫ�ֱ���
	lua_getglobal(L, "f");

	// ѹ�����
	lua_pushnumber(L, x);  // ��һ������
	lua_pushnumber(L, y);  // �ڶ�������

	// ���ã���������
	// pcall�Ĳ�����ָ��c�㴫��2������������һ��ֵ��û��errfunc
	// �����nargs���ȶ���һ�Σ��ضϻ�nil��
	// errfunc��ָ����������0��ʾû�У�����������������ջ�����������Ҫ�Ļ�����ѹ�뺯���Ͳ�����ѹ��errfunc
	// ������һС�ι��ڴ������������飬����ξͲ����ˣ���������Ƕ�״���Ŀ���
	if (lua_pcall(L, 2, 1, 0) != 0)
		printf("error running function 'f':%s", lua_tostring(L, -1));

	// �÷���ֵ������֤��������
	// �෵��ֵ��ʱ��Ҳ�ǵ�һ������ֵ��ѹ�룬�Դ�����
	if (!lua_isnumber(L, -1))
		printf("function 'f' must return a number");
	z = lua_tonumber(L, -1);

	// ��������ֵ���ָ�ջ
	lua_pop(L, 1);

	// ��c�㷵��ֵ
	return z;
}

// 25.3
// c����lua��������
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

// ͨ�õ�C����lua����
// ����: call_va("f", "dd>d", x, y, &z)
void call_va(lua_State *L, const char *func, const char *sig, ...)
{
	va_list vl;
	int narg, nres;
	va_start(vl, sig);
	lua_getglobal(L, func);

	// ѹ�����
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

	// �����
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

// ������ӿ��Ժ��ԣ�����ͼдһ��ͨ�õĵ��ú���������ʵ����û��Ҫ
// ���������ַ�����ʾ����ǩ�������ͣ��Ƿǳ�����׳��
// ���һ�����c��vararg�����˰���
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