/**lua程序设计2nd源代码
*/
#include <stdio.h>
#include <string.h>
#include <stdarg.h>


extern "C" {
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
}


#include <limits.h>
#include "header.h"
#include "pthread.h"

namespace luabook_30 {

typedef struct Proc
{
	lua_State *L;
	pthread_t thread;
	pthread_cond_t cond;
	const char *channel;
	struct Proc *previous, *next;
} Proc;

static Proc *waitSend = NULL;
static Proc *waitReceive = NULL;

static pthread_mutex_t kernel_access;

static Proc *getSelf(lua_State *L)
{
	Proc *p;
	lua_getfield(L,  LUA_REGISTRYINDEX, "_SELF");
	p = (Proc*)lua_touserdata(L, -1);
	lua_pop(L, 1);
	return p;
}

static void moveValues(lua_State *send, lua_State *rec)
{
	int n = lua_gettop(send);
	int i;
	for(i=2; i<=n; i++)
		lua_pushstring(rec, lua_tostring(send, i));
}

static Proc *searchMatch(const char *channel, Proc **list)
{
	Proc *node = *list;
	if (node==NULL)
		return NULL;
	do
	{
		if (strcmp(channel, node->channel)==0)
		{
			if(*list==node)
				*list = (node->next==node)? NULL :node->next;
			node->previous->next = node->next;
			node->next->previous = node->previous;
			return node;
		}
	}
	while(node!=*list);
	return NULL;
}

static void waitonlist(lua_State *L, const char *channel, Proc **list)
{
	Proc *p = getSelf(L);

	if(*list==NULL)
	{
		*list = p;
		p->previous = p->next = p;
	}
	else
	{
		p->previous = (*list)->previous;
		p->next = *list;
		p->previous->next = p->next->previous = p;
	}
	p->channel = channel;
	do
	{
		pthread_cond_wait(&p->cond, &kernel_access);
	}
	while(p->channel);
}

static int ll_send(lua_State *L)
{
	Proc *p;
	const char *channel = luaL_checkstring(L, 1);
	pthread_mutex_lock(&kernel_access);
	p = searchMatch(channel, &waitReceive);

	if(p)
	{
		moveValues(L, p->L);
		p->channel = NULL;
		pthread_cond_signal(&p->cond);
	}
	else
		waitonlist(L, channel, &waitSend);
	pthread_mutex_unlock(&kernel_access);
	return 0;
}

static int ll_receive(lua_State *L)
{
	Proc *p;
	const char *channel = luaL_checkstring(L, 1);
	lua_settop(L, 1);

	pthread_mutex_lock(&kernel_access);
	p = searchMatch(channel, &waitSend);

	if(p)
	{
		moveValues(p->L, L);
		p->channel = NULL;
		pthread_cond_signal(&p->cond);
	}
	else
		waitonlist(L, channel, &waitReceive);

	pthread_mutex_unlock(&kernel_access);
	return lua_gettop(L) - 1;
}

static void ll_thread(void *arg);

static int ll_start(lua_State *L)
{
	pthread_t thread;
	const char *chunk = luaL_checkstring(L, 1);
	lua_State *L1 = luaL_newstate();

	if(L1==NULL)
		luaL_error(L, "unable to create new state");

	if(luaL_loadstring(L1, chunk)!=0)
		luaL_error(L, "error starting thread:%s", lua_tostring(L1, -1));
	if(pthread_create(&thread, NULL, ll_thread, L1)!=0)
		luaL_error(L, "unable to create new thread");
	pthread_detach(thread);
	return 0;
}

int luaopen_lproc(lua_State *L);

static void ll_thread(void*arg)
{
	lua_State *L = (lua_State*)arg;
	luaL_openlibs(L);
	lua_cpcall(L, luaopen_lproc, NULL);
	if(lua_pcall(L, 0, 0, 0)!=0)
		fprintf(stderr, "thread error:%s", lua_tostring(L, -1));
	pthread_cond_destroy(&(getSelf(L)->cond));
	lua_close(L);
}

static int ll_exit(lua_State *L)
{
	pthread_exit(NULL);
	return 0;
}

static const struct luaL_reg ll_funcs[] = 
{
	{"start", ll_start},
	{"send", ll_send},
	{"receive", ll_receive},
	{"exit", ll_exit},
	{NULL, NULL},
};

int luaopen_lproc(lua_State *L)
{
	Proc *self = (Proc*)lua_newuserdata(L, sizeof(Proc));
	lua_setfield(L, LUA_REGISTRYINDEX, "_SELF");
	self->L = L;
	self->thread = pthread_self();
	self->channel = NULL;
	pthread_cond_init(&self->cond, NULL);
	luaL_register(L, "lproc", ll_funcs);
	return 1;
}


void test30_2(lua_State *L)
{
	luaopen_lproc(L);

	if(luaL_loadfile(L, "part4\\30_2.lua") || lua_pcall(L, 0, 0, 0))
		printf("cannot run config. file:%s\n", lua_tostring(L, -1));
}

	
}