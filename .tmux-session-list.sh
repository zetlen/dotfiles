tmux ls -F "#{?session_attached,🔳,◻️}  #S #{?session_alerts,⚠️, }"
