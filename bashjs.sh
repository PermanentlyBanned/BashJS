#!/bin/bash

declare -A vars

eval_expr() {
    local expr="$1"
    local trimmed
    trimmed=$(echo "$expr" | sed 's/^[ \t]*//;s/[ \t]*$//')
    
    if [[ "${trimmed:0:1}" == "\"" && "${trimmed: -1}" == "\"" ]] || \
       [[ "${trimmed:0:1}" == "'" && "${trimmed: -1}" == "'" ]]; then
        echo "${trimmed:1:-1}"
        return
    fi

    expr="${expr// /}"
    expr="${expr//;/}"

    local prev_expr=""
    while [[ "$expr" != "$prev_expr" ]]; do
        prev_expr="$expr"
        for key in "${!vars[@]}"; do
            expr="${expr//$key/${vars[$key]}}"
        done
    done

    if [[ "$expr" =~ ^[0-9+*/\(\)\.-]+$ ]]; then
        result=$(echo "$expr" | bc -l 2>/dev/null)
        echo "$result"
    else
        echo "$expr"
    fi
}

process_assignment() {
    local line="$1"
    var_name=$(echo "$line" | sed -E 's/^let[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*=.*$/\1/')
    var_value=$(echo "$line" | sed -E 's/^let[[:space:]]+[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*=[[:space:]]*(.+)$/\1/')
    eval_value=$(eval_expr "$var_value")
    vars["$var_name"]=$eval_value
}

process_log() {
    local line="$1"
    log_value=$(echo "$line" | sed -E 's/^console\.log\((.+)\);?$/\1/')
    result=$(eval_expr "$log_value")
    echo "$result"
}

process_wait() {
    local line="$1"
    local wait_expr
    wait_expr=$(echo "$line" | sed -E 's/^wait\((.+)\);?$/\1/')
    local wait_value
    wait_value=$(eval_expr "$wait_expr")
    sleep "$wait_value"
}

process_if() {
    local block="$1"
    local regex='if[[:space:]]*\(([^)]+)\)[[:space:]]*\{([^}]*)\}'
    if [[ "$block" =~ $regex ]]; then
        condition="${BASH_REMATCH[1]}"
        actions="${BASH_REMATCH[2]}"
        
        condition_result=$(eval_expr "$condition")
        
        if (( condition_result != 0 )); then
            IFS=';' read -r -a actions_array <<< "$actions"
            for action in "${actions_array[@]}"; do
                action=$(echo "$action" | sed 's/^[ \t]*//;s/[ \t]*$//')
                process_line "$action"
            done
        fi
    else
        echo "Failed to parse if statement: $block"
    fi
}

process_line() {
    local line="$1"
    line=$(echo "$line" | sed 's/^[ \t]*//;s/[ \t]*$//')

    if [[ "$line" =~ ^let[[:space:]]+[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*=[[:space:]]*.+ ]]; then
        process_assignment "$line"
    elif [[ "$line" =~ ^console\.log\(.+\)\;?$ ]]; then
        process_log "$line"
    elif [[ "$line" =~ ^wait\(.+\)\;?$ ]]; then
        process_wait "$line"
    elif [[ "$line" == if* ]]; then
        process_if "$line"
    fi
}

process_js_file() {
    local file="$1"
    local block=""
    local in_if=0
    while IFS= read -r line; do
        if [[ $in_if -eq 0 && "$line" =~ ^if[[:space:]]*\(.* ]]; then
            block="$line"
            if [[ "$line" != *"}"* ]]; then
                in_if=1
            else
                process_line "$block"
                block=""
            fi
        elif [[ $in_if -eq 1 ]]; then
            block="$block $line"
            if [[ "$line" == *"}"* ]]; then
                in_if=0
                process_line "$block"
                block=""
            fi
        else
            process_line "$line"
        fi
    done < "$file"
}

run_script() {
    if [[ -f "$1" ]]; then
        process_js_file "$1"
    else
        while IFS= read -r line; do
            process_line "$line"
        done
    fi
}

if [[ $# -eq 1 ]]; then
    run_script "$1"
else
    run_script
fi