TAB=$'\t'
# splitting aliases that set different IFSs, very useful for pipelines
# all follow the naming scheme `:<name>`
alias ':tab'="IFS=$'\t'" \
':colon'="IFS=':'" \
':semic'="IFS=';'" \
':lf'="IFS=$'\n'" \
':eq'="IFS='='"
