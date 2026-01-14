# Update pahoabc.schedule by editing the table below.
#
# Expected columns: dose, age_schedule, age_schedule_low, age_schedule_high

pahoabc.schedule <- data.frame(
  dose = c("SRP1", "DTP1", "DTP2", "DTP3", "BCG RN", "YFV1"),
  age_schedule = c(365, 60, 120, 180, 0, 365),
  age_schedule_low = c(360, 54, 116, 176, 0, 360),
  age_schedule_high = c(420, 90, 150, 210, 28, 420),
  stringsAsFactors = FALSE
)

print(pahoabc.schedule)

usethis::use_data(pahoabc.schedule, overwrite = TRUE)
