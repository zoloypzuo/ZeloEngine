# coding=utf-8
# main.py
# created on 2020/10/16
# author @zoloypzuo
# usage: main
import G
from common.zlogger import logger


@logger
def game_main():
    """
    init game
    :return:
    """
    import sys

    G.cmd_argv = sys.argv
    # ---------------------------------------------------
    # init app from commandline args
    # ---------------------------------------------------
    argc = len(G.cmd_argv)
    if argc < 2:
        print 'app not specified'
        return
    if argc > 2:
        use_glut = G.cmd_argv[2]
        print "use glut"
        from framework._archived.zgraphics_glut import Graphics
        G.graphicsm = Graphics()
    else:
        print "use glfw"
        from framework.zgraphics_glfw import Graphics
        G.graphicsm = Graphics()
    app_dir = G.cmd_argv[1]
    sys.path += [app_dir]
    app_main = app_dir + '\\app_main.py'
    execfile(app_main)
    # ---------------------------------------------------
    # init engine & start mainloop
    # ---------------------------------------------------
    G.main_initialize()
    G.appm.main()

@logger
def game_main_from_app(app, use_glut=False):
    import sys

    G.cmd_argv = sys.argv
    G.use_glut = use_glut
    app()
    if use_glut:
        print "use glut"
        from framework._archived.zgraphics_glut import Graphics
        G.graphicsm = Graphics()
    else:
        print "use glfw"
        from framework.zgraphics_glfw import Graphics
        G.graphicsm = Graphics()
    G.main_initialize()
    G.appm.main()

if __name__ == '__main__':
    game_main()
