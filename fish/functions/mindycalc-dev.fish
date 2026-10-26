function mindycalc-dev
    set proj ~/Mindycalc2
    cd $proj

    kitty --directory $proj fish -C "source .venv/bin/activate.fish" -c "exec nvim ." &
    sleep 0.1
    kitty --directory $proj fish -C "source .venv/bin/activate.fish" -c "exec nvim ." &
    sleep 0.1

    source .venv/bin/activate.fish
    clear
end
