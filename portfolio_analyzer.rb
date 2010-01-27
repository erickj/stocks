require 'net/smtp'
require 'yaml'
require 'lib/stock_quote'

email_to = 'ejohnson82@gmail.com'
email_from = 'erick@ejjohnson.org'
email_subj = "Stock Update: %s"%Time.now.strftime('%m/%d/%Y')

symbols_file = "data/symbols.txt"
history_file = "data/history.yml"

symbol_message_tpl = <<EOF
Symbol: %s
\tPrice: %s
\tChange: %s

EOF

symbols = File.open(symbols_file).readlines
results = YAML.load_file(history_file) rescue {}

message = ""

uri = nil
val = nil

symbols.each do |symbol|
  symbol.gsub!(/\s/,'')
  val = StockQuote.get_quote_for_symbol(symbol)

  begin
    results[symbol].push(val)
  rescue
    results[symbol] = [val]
  end

  yesterday = results[symbol][-2]
  change = ((val - yesterday.to_f).to_f * (100).to_f).round / 100.to_f if yesterday

  message << symbol_message_tpl%[symbol,val,change]
end

File.open(history_file,'w') do |out|
  YAML.dump(results,out)
end

Net::SMTP.start('localhost',25) do |smtp|
  smtp.open_message_stream(email_from, email_to) do |f|
    f.puts 'From: %s'%email_from
    f.puts 'To: %s'%email_to
    f.puts 'Subject: %s'%email_subj
    f.puts
    f.puts message
  end
end
