// CraftPlugin.cpp
// created on 2021/11/23
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "CraftPlugin.h"

#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <ctime>

#include "config.h"
#include "cube.h"
#include "db.h"
#include "item.h"
#include "map.h"
#include "matrix.h"
#include "lib/noise.h"
#include "sign.h"
#include "lib/tinycthread.h"
#include "util.h"
#include "world.h"

#define MAX_CHUNKS 8192
#define MAX_PLAYERS 128
#define WORKERS 4
#define MAX_TEXT_LENGTH 256
#define MAX_NAME_LENGTH 32
#define MAX_PATH_LENGTH 256
#define MAX_ADDR_LENGTH 256

#define ALIGN_LEFT 0
#define ALIGN_CENTER 1
#define ALIGN_RIGHT 2

#define MODE_OFFLINE 0
#define MODE_ONLINE 1

#define WORKER_IDLE 0
#define WORKER_BUSY 1
#define WORKER_DONE 2


typedef struct {
    Map map;
    Map lights;
    SignList signs;
    int p;
    int q;
    int faces;
    int sign_faces;
    int dirty;
    int miny;
    int maxy;
    GLuint buffer;
    GLuint sign_buffer;
} Chunk;

typedef struct {
    int p;
    int q;
    int load;
    Map *block_maps[3][3];
    Map *light_maps[3][3];
    int miny;
    int maxy;
    int faces;
    GLfloat *data;
} WorkerItem;

typedef struct {
    int index;
    int state;
    thrd_t thrd;
    mtx_t mtx;
    cnd_t cnd;
    WorkerItem item;
} Worker;

typedef struct {
    int x;
    int y;
    int z;
    int w;
} Block;

typedef struct {
    float x;
    float y;
    float z;
    float rx;
    float ry;
    float t;
} State;

typedef struct {
    int id;
    char name[MAX_NAME_LENGTH];
    State state;
    State state1;
    State state2;
    GLuint buffer;
} Player;

typedef struct {
    GLuint program;
    GLuint position;
    GLuint normal;
    GLuint uv;
    GLuint matrix;
    GLuint sampler;
    GLuint camera;
    GLuint timer;
    GLuint extra1;
    GLuint extra2;
    GLuint extra3;
    GLuint extra4;
} Attrib;

typedef struct {
    GLFWwindow *window;
    Worker workers[WORKERS];
    Chunk chunks[MAX_CHUNKS];
    int chunk_count;
    int create_radius;
    int render_radius;
    int delete_radius;
    int sign_radius;
    Player players[MAX_PLAYERS];
    int player_count;
    int typing;
    char typing_buffer[MAX_TEXT_LENGTH];
    int message_index;
    char messages[MAX_MESSAGES][MAX_TEXT_LENGTH];
    int width;
    int height;
    int observe1;
    int observe2;
    int flying;
    int item_index;
    int scale;
    int ortho;
    float fov;
    int suppress_char;
    int mode;
    int mode_changed;
    char db_path[MAX_PATH_LENGTH];
    char server_addr[MAX_ADDR_LENGTH];
    int server_port;
    int day_length;
    int time_changed;
    Block block0;
    Block block1;
    Block copy0;
    Block copy1;
} Model;

static Model model;
static Model *g = &model;

int worker_run(void *arg) {
    Worker *worker = (Worker *) arg;
    int running = 1;
    while (running) {
        mtx_lock(&worker->mtx);
        while (worker->state != WORKER_BUSY) {
            cnd_wait(&worker->cnd, &worker->mtx);
        }
        mtx_unlock(&worker->mtx);
        WorkerItem *item = &worker->item;
        if (item->load) {
//            load_chunk(item); TODO
        }
//        compute_chunk(item); TODO
        mtx_lock(&worker->mtx);
        worker->state = WORKER_DONE;
        mtx_unlock(&worker->mtx);
    }
    return 0;
}

const std::string &CraftPlugin::getName() const {
    static std::string s("CraftPlugin");
    return s;
}

void CraftPlugin::install() {
    // INITIALIZATION //
    srand(time(NULL));
    rand();


    // INITIALIZE WORKER THREADS
    for (int i = 0; i < WORKERS; i++) {
        Worker *worker = g->workers + i;
        worker->index = i;
        worker->state = WORKER_IDLE;
        mtx_init(&worker->mtx, mtx_plain);
        cnd_init(&worker->cnd);
        thrd_create(&worker->thrd, worker_run, worker);
    }

    // DATABASE INITIALIZATION //
    if (g->mode == MODE_OFFLINE || USE_CACHE) {
        db_enable();
        if (db_init(g->db_path)) {
//            return -1;
        }
    }

    // LOCAL VARIABLES //
//    reset_model(); TODO
    double last_commit = glfwGetTime();
    double last_update = glfwGetTime();
//    GLuint sky_buffer = gen_sky_buffer(); TODO

    Player *me = g->players;
    State *s = &g->players->state;
    me->id = 0;
    me->name[0] = '\0';
    me->buffer = 0;
    g->player_count = 1;

    // LOAD STATE FROM DATABASE //
    int loaded = db_load_state(&s->x, &s->y, &s->z, &s->rx, &s->ry);
//    force_chunks(me); TODO
    if (!loaded) {
//        s->y = highest_block(s->x, s->z) + 2; TODO
    }

}

void CraftPlugin::shutdown() {
    // SHUTDOWN //
    State *s = &g->players->state;
    db_save_state(s->x, s->y, s->z, s->rx, s->ry);
    db_close();
    db_disable();
//    del_buffer(sky_buffer);
//    delete_all_chunks();
//    delete_all_players();
}

