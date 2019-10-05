local sets = {}

-- Walls are kind of "misc"

sets.walls_easy = {"DenseRocks", "InsanityWall"}
sets.walls_hard = {"SanityWall"}
sets.all_walls = ArrayUnion(sets.walls_easy, sets.walls_hard)

-- By Monsters

sets.chess_easy = {}
sets.chess_hard = {"Chessfield","ChessfieldA", "ChessfieldB", "ChessfieldC" }
sets.all_chess = ArrayUnion( sets.chess_easy, sets.chess_hard )

sets.tallbirds_easy = {"TallbirdfieldSmallA","Tallbirdfield"}
sets.tallbirds_hard = {"TallbirdfieldA", "TallbirdfieldB"}
sets.all_tallbirds = ArrayUnion( sets.tallbirds_easy, sets.tallbirds_hard )

sets.spiders_easy = {"SpiderfieldEasy", "SpiderfieldEasyA", "SpiderfieldEasyB"}
sets.spiders_hard = {"Spiderfield", "SpiderfieldA", "SpiderfieldB", "SpiderfieldC"}
sets.all_spiders = ArrayUnion( sets.spiders_easy, sets.spiders_hard )

sets.bees_easy = {"Waspnests"}
sets.bees_hard = {}
sets.all_bees = ArrayUnion(sets.bees_easy, sets.bees_hard)

sets.pigs_easy = {"PigGuardpostEasy"}
sets.pigs_hard = {"PigGuardpost", "PigGuardpostB"}
sets.all_pigs = ArrayUnion( sets.pigs_easy, sets.pigs_hard )

sets.tentacles_easy = {"TentaclelandSmallA"}
sets.tentacles_hard = {"TentaclelandA", "Tentacleland"}
sets.all_tentacles = ArrayUnion( sets.tentacles_easy, sets.tentacles_hard )

sets.merms_easy = {}
sets.merms_hard = { "Mermfield" }
sets.all_merms = ArrayUnion( sets.merms_easy, sets.merms_hard )

sets.hounds_easy = {}
sets.hounds_hard = {"Moundfield" }
sets.all_hounds = ArrayUnion( sets.hounds_easy, sets.hounds_hard )

-- By terrain

sets.forest_easy = ArrayUnion( sets.spiders_easy, sets.pigs_easy )
sets.forest_hard = ArrayUnion( sets.spiders_hard, sets.pigs_hard )
sets.all_forest = ArrayUnion( sets.forest_easy, sets.forest_hard )

sets.rocky_easy = ArrayUnion( sets.tallbirds_easy, sets.pigs_easy, sets.hounds_easy )
sets.rocky_hard = ArrayUnion( sets.tallbirds_hard, sets.pigs_hard, sets.hounds_hard )
sets.all_rocky = ArrayUnion( sets.rocky_easy, sets.rocky_hard )

sets.grass_easy = ArrayUnion( sets.bees_easy, sets.pigs_easy )
sets.grass_hard = ArrayUnion( sets.bees_hard, sets.pigs_hard )
sets.all_grass = ArrayUnion( sets.grass_easy, sets.grass_hard )

sets.marsh_easy = ArrayUnion( sets.tentacles_easy, sets.merms_easy )
sets.marsh_hard = ArrayUnion( sets.tentacles_hard, sets.merms_hard )
sets.all_marsh = ArrayUnion( sets.marsh_easy, sets.marsh_hard )

-- Some special seasonal ones...

sets.winter_hard = { "Deerclopsfield", "Walrusfield" }

-- Meta-sets
sets.all_easy = ArrayUnion( sets.pigs_easy,
							sets.spiders_easy,
							sets.tallbirds_easy,
							sets.chess_easy,
							sets.tentacles_easy,
							sets.walls_hard )

sets.all_hard = ArrayUnion( sets.pigs_hard,
							sets.spiders_hard,
							sets.tallbirds_hard,
							sets.chess_hard,
							sets.tentacles_hard,
							sets.walls_hard )

-- Note, this "all" actually skips out on some super-specific ones like the winter ones.
sets.all = ArrayUnion(sets.all_easy, sets.all_hard)

sets.all_hard_winter = ArrayUnion(sets.all_hard, sets.winter_hard)

return sets
