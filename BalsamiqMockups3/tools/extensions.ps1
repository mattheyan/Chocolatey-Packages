function ParseParameters ([string]$parameters) {
    $arguments = @{};

    if ($parameters) {
        $match_pattern = "(?:\s*)(?<=[-|/])(?<option>\w*)[:|=](`"((?<value>.*?)(?<!\\)`")|(?<value>[\w]*))"
        #"
        $optionName = 'option'
        $valueName = 'value'
        
        if ($parameters -match $match_pattern ){
            $results = $parameters | Select-String $match_pattern -AllMatches
            $results.matches | % {
              $arguments.Add(
                  $_.Groups[$optionName].Value.Trim(),
                  $_.Groups[$valueName].Value.Trim())
          }
        }
        else
        {
          throw "Package Parameters were found but were invalid (REGEX Failure)"
        }
    }
    
    return $arguments;
}