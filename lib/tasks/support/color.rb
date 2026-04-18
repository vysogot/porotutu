# frozen_string_literal: true

module Color
  RESET = "\e[0m"
  BOLD = "\e[1m"
  RED = "\e[31m"
  GREEN = "\e[32m"
  YELLOW = "\e[33m"
  CYAN = "\e[36m"
  DIM = "\e[2m"

  def self.header(text) = "#{BOLD}#{CYAN}#{text}#{RESET}"
  def self.success(text) = "#{GREEN}#{text}#{RESET}"
  def self.error(text) = "#{RED}#{text}#{RESET}"
  def self.skipped(text) = "#{YELLOW}#{text}#{RESET}"
  def self.path(text) = "#{DIM}#{text}#{RESET}"
  def self.label(text) = "#{BOLD}#{text}#{RESET}"
end
