##     -s, --some-lib-option   This is an additional option.
some-lib-feature()
{
    [[ -n "$some_lib_option" ]] && echo "Some lib option: $some_lib_option"
}
