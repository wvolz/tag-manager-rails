// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "popper"
import "bootstrap"
import LocalTime from "local-time"
LocalTime.start()
document.addEventListener("turbo:morph", () => {
  LocalTime.run()
})
