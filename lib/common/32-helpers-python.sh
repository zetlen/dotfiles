pip() {
    python -m pip "$@"
}

p_vadd() {
    pip install --upgrade $@ && pip freeze > requirements.txt
}

gpip() {
    PIP_REQUIRE_VIRTUALENV="" python -m pip "$@"
}

alias p_vinit="python -m venv venv && source ./venv/bin/activate"
alias p_vactivate="source ./venv/bin/activate"
alias p_vfreeze="python -m pip freeze > requirements.txt"
alias p_vinstall="python -m pip install -r requirements.txt"
