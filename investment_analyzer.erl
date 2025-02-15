-module(investment_analyzer).
-export([analyze_news/0]).

% ============================
% Investment News Analyzer
% Reads investment news, extracts detailed data, evaluates risk, 
% and provides investment recommendations with insights.
% ============================

% Main function to analyze investment news
analyze_news() ->
    io:format("INVESTMENT NEWS ANALYSIS STARTED...~n"),

    case file:read_file("investment_news.txt") of
        {ok, BinaryData} ->
            Text = unicode:characters_to_list(BinaryData, utf8),  % Ensure UTF-8 decoding
            Sections = string:split(Text, "\n\n", all),
            process_sections(Sections);
        {error, Reason} ->
            io:format("ERROR: Unable to read news file: ~p~n", [Reason])
    end.

% ============================
% Process Each News Section
% ============================

process_sections([]) ->
    io:format("ANALYSIS COMPLETE. END OF REPORT.~n");
process_sections([Section | Rest]) ->
    analyze_news_section(Section),
    process_sections(Rest).

% ============================
% Extract Information & Analyze
% ============================

analyze_news_section(Section) ->
    {Category, Headline, Source, Risk, Volatility, Trend, Market, Sector, History} = extract_info(Section),
    InvestmentAdvice = generate_advice(Risk, Volatility, Trend, Market, History),

    io:format("\n----------------------------------------------~n"),
    io:format("Category: ~s~n", [Category]),
    io:format("Headline: ~s~n", [Headline]),
    io:format("Source: ~s~n", [Source]),
    io:format("Risk Level: ~s~n", [Risk]),
    io:format("Volatility: ~s~n", [Volatility]),
    io:format("Trend: ~s~n", [Trend]),
    io:format("Market Condition: ~s~n", [Market]),
    io:format("Sector: ~s~n", [Sector]),
    io:format("Historical Performance: ~s~n", [History]),
    io:format("Investment Advice: ~s~n", [InvestmentAdvice]).

% ============================
% Extract News Data
% ============================

extract_info(Section) ->
    Lines = string:split(Section, "\n", all),
    Headline = extract_quoted_text(lists:nth(1, Lines)),
    Category = extract_category(lists:nth(1, Lines), Headline),  
    Source = get_line_value(2, Lines, "Unknown"),
    Risk = get_line_value(3, Lines, "Unknown"),
    Volatility = get_line_value(4, Lines, "Unknown"),
    Trend = get_line_value(5, Lines, "Unknown"),
    Market = get_line_value(6, Lines, "Unknown"),
    Sector = get_line_value(7, Lines, "Unknown"),
    History = get_line_value(8, Lines, "Unknown"),
    {Category, Headline, Source, Risk, Volatility, Trend, Market, Sector, History}.

% ============================
% Fix Category Extraction
% ============================

extract_category(Line, Headline) ->
    case re:run(Line, "\\*\\*(.*?)\\*\\*", [{capture, all_but_first, list}]) of
        {match, [Category]} -> Category;
        nomatch -> extract_first_word(Headline)  
    end.

extract_first_word(Headline) ->
    case string:split(Headline, " ", all) of
        [First | _] -> First;
        _ -> "Unknown"
    end.

% ============================
% Extract Text Helper Functions
% ============================

extract_quoted_text(Line) ->
    case re:run(Line, "\"(.*?)\"", [{capture, all_but_first, list}]) of
        {match, [Text]} -> Text;
        nomatch -> "Unknown"
    end.

get_line_value(Index, Lines, Default) ->
    case lists:nth(Index, Lines) of
        Line -> extract_value(Line, Default);
        _ -> Default
    end.

extract_value(Line, Default) ->
    case re:run(Line, ": (.*)", [{capture, all_but_first, list}]) of
        {match, [Value]} -> string:trim(Value);
        nomatch -> Default
    end.

% ============================
% Generate Investment Advice
% ============================

generate_advice("High", "High", "Bullish", "Strong", "Up 12% last month") -> 
    "High-risk, high-reward opportunity! Consider but proceed with caution!";
generate_advice("Low", "Low", "Bullish", "Stable", "Up 5% last month") -> 
    "Safe investment. Good for long-term holding!";
generate_advice("Medium", "Medium", "Bullish", "Strong", "Up 8% last month") -> 
    "Promising but monitor closely!";
generate_advice("High", "Medium", "Bearish", "Declining", "Down 7% last month") -> 
    "Risky investment. Avoid unless you can handle losses!";
generate_advice("Low", "High", "Bearish", "Weak", "Down 3% last month") -> 
    "High volatility. Avoid this asset!";
generate_advice(_, _, "Bearish", "Declining", _) -> 
    "Market is going down. Not recommended!";
generate_advice(_, _, "Bullish", "Strong", "Up 10% last month") -> 
    "Positive trend. This could be a good investment!";
generate_advice(_, _, _, _, _) -> 
    "Watch closely before making a decision.".