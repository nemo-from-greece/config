function watch
    argparse 'y/youtube=' 't/twitch=' -- $argv
    or return

    if set -q _flag_youtube
        set -l id $_flag_youtube
        if not string match -q 'http*' -- $id
            set id "https://www.youtube.com/watch?v=$id"
        end
        mpv $id $argv
    else
        mpv $argv
    end

    if set -q _flag_twitch
        set -l id $_flag_twitch
        if not string match -q 'http*' -- $id
            set id "https://www.twitch.tv/$id"
        end
        mpv $id $argv
    else
        mpv $argv
    end
end
