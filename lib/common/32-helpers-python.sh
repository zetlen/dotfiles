alias p_vinit="python -m venv venv && source ./venv/bin/activate"
alias p_vactivate="source ./venv/bin/activate"
alias p_vfreeze="pip freeze > requirements.txt"
alias p_vinstall="pip install -r requirements.txt"

p_vadd() {
  pip install --upgrade $1 && pip freeze > requirements.txt
}
