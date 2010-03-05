require 'net/http'

class StockQuote
  URL_TEMPLATE = "http://download.finance.yahoo.com/d/quotes.csv?s=%s&f=%s"
  API_ARGS = {
    :'ask' => 'a',
    :'average daily volume' => 'a2',
    :'ask size' => 'a5',
    :'bid' => 'b',
    :'ask (real-time)' => 'b2',
    :'bid (real-time)' => 'b3',
    :'book value' => 'b4',
    :'bid size' => 'b6',
    :'change & percent change' => 'c',
    :'change' => 'c1',
    :'commission' => 'c3',
    :'change (real-time)' => 'c6',
    :'after hours change (real-time)' => 'c8',
    :'dividend/share' => 'd',
    :'last trade date' => 'd1',
    :'trade date' => 'd2',
    :'earnings/share' => 'e',
    :'error indication (returned for symbol changed / invalid)' => 'e1',
    :'eps estimate current year' => 'e7',
    :'eps estimate next year' => 'e8',
    :'eps estimate next quarter' => 'e9',
    :'float shares' => 'f6',
    :'days low' => 'g',
    :'days high' => 'h',
    :'52-week low' => 'j',
    :'52-week high' => 'k',
    :'holdings gain percent' => 'g1',
    :'annualized gain' => 'g3',
    :'holdings gain' => 'g4',
    :'holdings gain percent (real-time)' => 'g5',
    :'holdings gain (real-time)' => 'g6',
    :'more info' => 'i',
    :'order book (real-time)' => 'i5',
    :'market capitalization' => 'j1',
    :'market cap (real-time)' => 'j3',
    :'ebitda' => 'j4',
    :'change from 52-week low' => 'j5',
    :'percent change from 52-week low' => 'j6',
    :'last trade (real-time) with time' => 'k1',
    :'change percent (real-time)' => 'k2',
    :'last trade size' => 'k3',
    :'change from 52-week high' => 'k4',
    :'percebt change from 52-week high' => 'k5',
    :'last trade (with time)' => 'l',
    :'last trade (price only)' => 'l1',
    :'high limit' => 'l2',
    :'low limit' => 'l3',
    :'days range' => 'm',
    :'days range (real-time)' => 'm2',
    :'50-day moving average' => 'm3',
    :'200-day moving average' => 'm4',
    :'change from 200-day moving average' => 'm5',
    :'percent change from 200-day moving average' => 'm6',
    :'change from 50-day moving average' => 'm7',
    :'percent change from 50-day moving average' => 'm8',
    :'name' => 'n',
    :'notes' => 'n4',
    :'open' => 'o',
    :'previous close' => 'p',
    :'price paid' => 'p1',
    :'change in percent' => 'p2',
    :'price/sales' => 'p5',
    :'price/book' => 'p6',
    :'ex-dividend date' => 'q',
    :'p/e ratio' => 'r',
    :'dividend pay date' => 'r1',
    :'p/e ratio (real-time)' => 'r2',
    :'peg ratio' => 'r5',
    :'price/eps estimate current year' => 'r6',
    :'price/eps estimate next year' => 'r7',
    :'symbol' => 's',
    :'shares owned' => 's1',
    :'short ratio' => 's7',
    :'last trade time' => 't1',
    :'trade links' => 't6',
    :'ticker trend' => 't7',
    :'1 yr target price' => 't8',
    :'volume' => 'v',
    :'holdings value' => 'v1',
    :'holdings value (real-time)' => 'v7',
    :'52-week range' => 'w',
    :'days value change' => 'w1',
    :'days value change (real-time)' => 'w4',
    :'stock exchange' => 'x',
    :'dividend yield' => 'y'
  }

  class << self
    def series_high(data_points,max=nil)
      max ||= 52 * 5 # 52 weeks
      data_points.last(max).max
    end

    def series_low(data_points,max=nil)
      max ||= 52 * 5 # 52 weeks
      data_points.last(max).min
    end

    def simple_moving_average(data_points)
      val = data_points.inject do |sum, n|
        sum + n
      end / data_points.length

      StockQuote.round(val)
    end

    def calculate_series(data_set, time_frame, iterations, &block)
      if (time_frame + iterations) < data_set.length
        raise ArgumentError, "time_frame + iterations must be greater than data_set length" 
      end

      idx = -(time_frame.abs)
      res = []
            
      until res.length >= iterations do
        res.push(yield(data_set[idx,time_frame]))
        idx -= 1
      end

      res.reverse
    end

    def get_quote_for_symbol(symbol)
      uri = URL_TEMPLATE%[symbol, API_ARGS[:'last trade (price only)']]
      val = Net::HTTP.get(URI.parse(uri))
      return val && val.to_f
    end

    protected
    def round(v,places=2)
      mul = (10**places).to_f
      (v.to_f * mul).round / mul
    end
  end
end
