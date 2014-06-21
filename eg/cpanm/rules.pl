# colorize cpanm output
[
    qr{--> Working on (\S+)},
    [ qw( maintask module ) ],

    qr{(\S+) is up to date. \(([^)]+)\)},
    [ qw( uptodate module version ) ],

    qr{Fetching (\S+) \.\.\. (\S+)},
    [ qw( fetchtask url status ) ],

    qr{Configuring (\S+) \.\.\. (\S+)},
    [ qw( configtask release status ) ],

    qr{Building and testing (\S+) \.\.\. (\S+)},
    [ qw( buildtask release status ) ],

    qr{Successfully installed (\S+)},
    [ qw( success release ) ],

    qr{==> Found dependencies: (.*)},
    [ qw( founddeps modulelist ) ],

    qr{(\d+) distributions installed},
    [ qw( distsinstalled counter ) ],
]
