<a href="https://rubygems.org/gems/trees" title="Install gem"><img src="https://badge.fury.io/rb/trees.svg" alt="Gem version" height="18"></a> <a href="https://github.com/raindeer-rb/trees" title="GitHub"><img src="https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white" alt="GitHub repo" height="18"></a> <a href="https://codeberg.org/Iow/trees" title="Codeberg"><img src="https://img.shields.io/badge/Codeberg-2185D0?style=for-the-badge&logo=Codeberg&logoColor=white" alt="Codeberg repo" height="18"></a>

# Trees 🌲🌲🌲 [UNRELEASED]

Terminals are so vague. You have commands, sub commands, args, flags and `ENV` variables. All seperated by spaces, dashes and equals signs when really all you have is a line of text.

CLI frameworks are vague too. They let you build your beautiful structure... component by component, then map user input to those components.

Trees just gets you to write what the literal user input will be, then breaks it down into a nested tree of possible commands, subcommands and options. Think of your commands as routes with params. Think of the structure as a tree 🌲.

## Example

Taken from [Rain CLI](https://github.com/raindeer-rb/rain-cli) which powers the [Raindeer](https://raindeer.dev) web framework.

```ruby
line('new :app_name') do |app_name|
  execute { Rain::CLI::Template.build(app_name) }

  line('--with-db', '-d') do |app_name|
    summary { 'Set up your application with a database.' }
    execute { Rain::CLI::Template.build(app_name, db: true) }
  end
end

line('static build') do
  execute { Static.build }
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

## Execution Behaviour

Trees will execute the deepest match with an `execute` block so that you can add `summary` blocks for flags without doubling up on `execute` blocks:

```ruby
line('new :app_name') do |app_name, with_db:|
  execute { Rain::CLI::Template.build(app_name, db: with_db) }

  line('--with-db', '-d') do
    summary { 'Set up your application with a database.' }
  end
end
```

The above structure is equivalent to:
```ruby
line('new :app_name') do |app_name|
  execute { Rain::CLI::Template.build(app_name) }

  line('--with-db', '-d') do |app_name|
    summary { 'Set up your application with a database.' }
    execute { Rain::CLI::Template.build(app_name, db: true) }
  end
end
```

## API

Different placeholders in your string represent different data types.

### `:variable`

...

### `--flag`, `-f`

...

### `subcommand`

The literal text with no special characters will be interpreted as a subcommand.

...

### Summary block

Add a `summary` to a command, sub command or fla:

```ruby
line('static build') do
  summary { 'Build your static site' }
end
```
