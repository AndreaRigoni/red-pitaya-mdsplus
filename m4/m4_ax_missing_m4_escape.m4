# m4_escape(STRING)
# -----------------
m4_ifndef([m4_escape], 
 m4_define([m4_escape],
   [m4_if(m4_index(m4_translit([$1],
   [[]#,()]]m4_dquote(m4_defn([m4_cr_symbols2]))[, [$$$]), [$]),
   [-1], [m4_echo], [_$0])([$1])]))

m4_ifndef([_m4_escape], 
 m4_define([_m4_escape],
 [m4_changequote([-=<{(],[)}>=-])]dnl
 [m4_bpatsubst(m4_bpatsubst(m4_bpatsubst(m4_bpatsubst(
          -=<{(-=<{(-=<{(-=<{(-=<{($1)}>=-)}>=-)}>=-)}>=-)}>=-,
        -=<{(#)}>=-, -=<{(@%:@)}>=-),
      -=<{(\[)}>=-, -=<{(@<:@)}>=-),
    -=<{(\])}>=-, -=<{(@:>@)}>=-),
  -=<{(\$)}>=-, -=<{(@S|@)}>=-)m4_changequote([,])]))
