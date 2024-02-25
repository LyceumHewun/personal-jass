function StartWith takes string s, string prefix returns boolean
    return SubString(s, 0, StringLength(prefix)) == prefix
endfunction