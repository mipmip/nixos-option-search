# Copyright 2024 Pim Snel <post@pimsnel.com>
# License: MIT

require 'json'
require 'pp'

if not ENV['RELEASE']
  ENV['RELEASE'] = "master"
end

p ENV['RELEASE']

in_file = File.read("data/flake-nixos-#{ENV['RELEASE']}.json")

parsed = JSON.parse(in_file)

def isLiteralExpression(val, key)
  if val.key? key and val[key].instance_of? Hash and val[key].key? "_type" and val[key]['_type'] == 'literalExpression'
    true
  else
    false
  end
end

def getValFor(val, key)
  if isLiteralExpression(val, key)
    val[key]['text']
  elsif val.key? key
    val[key]
  else
    ""
  end
end


def parseVal(val)
  #val['declarations'] = [val['option_source']]
  val['declarations'] = {}
  val['title'] = val['option_name']
  val['description'] = val['option_description']
  val['type'] = val['option_type']
  val['default'] = val['option_default']
  val['example'] = val['option_example']

  val.delete 'option_source'
  val.delete 'option_name'
  val.delete 'option_description'
  val.delete 'option_type'
  val.delete 'option_example'
  val.delete 'option_flake'

  val
end

options_arr = []
parsed.each do | item |

  #next if name == '_module.args'
  next if item['type'] != "option"

  val = parseVal(item)

  options_arr << val
end

outobj = {}
time = Time.new
outobj["last_update"] = time.utc.strftime("%B %d, %Y at %k:%M UTC")
outobj["options"] = options_arr

filename = "static/data/options-release-#{ENV['RELEASE']}.json"

File.open(filename,"w") do |f|
    f.write(outobj.to_json)
end

print "Finished parsing NixOS options."
