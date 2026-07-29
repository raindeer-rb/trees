<a href="https://rubygems.org/gems/trees" title="Install gem"><img src="https://badge.fury.io/rb/trees.svg" alt="Gem version" height="18"></a> <a href="https://github.com/raindeer-rb/trees" title="GitHub"><img src="https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white" alt="GitHub repo" height="18"></a> <a href="https://codeberg.org/Iow/trees" title="Codeberg"><img src="https://img.shields.io/badge/Codeberg-2185D0?style=for-the-badge&logo=Codeberg&logoColor=white" alt="Codeberg repo" height="18"></a>

# Trees 🌲 [UNRELEASED]

Terminals are so vague. You have commands, sub commands, args, flags and `ENV` variables. All seperated by spaces, dashes and equals signs. When really all you have is a line of text.

Current CLI frameworks are also vague. They let you build your beautiful structure... component by component, then map user input to those components.

Trees just gets you to write what the literal user input will be, then breaks it down into a nested tree of possible commands, subcommands and options. Think of your commands as routes with params. Think of the structure as a tree 🌲.

## Example

Taken from Rain CLI which powers the Raindeer web framework.

```ruby
line('new :app_name') do |args|
  execute { Rain::CLI::Template.build(args[:app_name]) }
end

line('static build') do
  execute { Static.build }
end

line('switch build') do
  execute { Switch.build }

  line('--reset-delay') do
    execute { Switch.build(reset_delay: true) }
  end
end
```

## Nested VS Flat

The following structures are equivalent and produce the same tree-like structure internally:

**Nested:**
```ruby
line('switch build') do
  execute { Switch.build }

  line('--reset-delay') do
    execute { Switch.build(reset_delay: true) }
  end
end
```

**Flat:**
```ruby
line('switch build') do
  execute { Switch.build }
end

line('switch build --reset-delay') do
  execute { Switch.build(reset_delay: true) }
end
```

## Data Types

Different placeholders in your string represent different data types.

### `:variable`

...

### `--flag`, `-f`

...

### `subcommand`

The literal text with no special characters will be interpreted as a subcommand.

...

## Descriptions

Add a `help` keyword argument like:

```ruby
line('static build', help: 'Build your static site') do
  execute { Static.build }
end
```
