# recipe for printing a tsv review of TMRs with jq

# util to join on space
def sjoin: [.[] | tostring] | join(" ");

# year accessor for dates
def get_year: .  | gmtime | .[0];

# string formatting for date
def label_time_interval($l):
  . as $t
  | if $t == 1 then $l else ($l + "s") end
  | [$t, .]
  | sjoin;

# date strflocaltime formatting
def date_format_for:
  "%a %Y/%m/%d %I:%M%p" as $f
  | if (now | get_year) != (. | get_year) then $f else ($f | sub("%Y/"; "")) end;

# print humanized durations
def human_duration:
  { day: (. /60/60/24 | floor), hour: (. /60/60%24), minute: (. /60%60), second: (. %60) }
  | to_entries
  | map(select(.value > 0 or .key == "second"))
  | map(. as $v | $v.value | label_time_interval($v.key))
  | (. | length) as $len
  | if $len > 2 then ((.[:-2] | map(. + ",")) + .[-2:]) else . end
  | if $len > 1 then (.[:-1] + ["and", last]) else . end
  | sjoin;

# interpolate data path wigh sed
%%DATA_PATH%%
  
# format item as a row
| map(
  . as $r
  | 
  [.name, (.duration | human_duration), (.start_date | strflocaltime(. | date_format_for))])
# add column headers and separators to beginning
| [["Name", "Took", "Began"], ["-------", "-------", "-------"]] + .
# display as tab separated values
| .[] | @tsv
