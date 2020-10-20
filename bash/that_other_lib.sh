##     -t, --that-option       That is the option.
that-other-feature()
{
    [[ -n "$that_option" ]] && echo "That other option: $that_option"
}

