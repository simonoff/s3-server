Before do |scenario|
  @current_scenario_key = scenario.title
end

After do
  S3Client.previous_scenario_key = @current_scenario_key
end
