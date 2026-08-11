<a href="https://rubygems.org/gems/trees" title="Install gem"><img src="https://badge.fury.io/rb/trees.svg" alt="Gem version" height="18"></a> <a href="https://github.com/raindeer-rb/trees" title="GitHub"><img src="https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white" alt="GitHub repo" height="18"></a> <a href="https://codeberg.org/Iow/trees" title="Codeberg"><img src="https://img.shields.io/badge/Codeberg-2185D0?style=for-the-badge&logo=Codeberg&logoColor=white" alt="Codeberg repo" height="18"></a>

# Trees 🌲🌲🌲

Terminals are so vague. You have commands, sub commands, args, flags and `ENV` variables. All separated by spaces, dashes and equals signs... when really all you have is a line of text.

CLI frameworks are vague too. You build your beautiful structure then map user input to those components. But now there's a translation gap between the structure you've defined and what the user types.

Trees just gets you to write what the literal user input will be, then breaks it down into a tree of commands, subcommands and options if need be. Think of your commands as routes with params. Think of the structure as a tree 🌲.

## Example

Taken from [Rain CLI](https://github.com/raindeer-rb/raindeer/blob/main/lib/cli/cli.rb) which powers the [Raindeer](https://raindeer.dev) web framework.

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

## Autocomplete [UNRELEASED]

Because all the lines are stored as a prefix tree (AKA Trie), you get an autocomplete for free!

## Execution Behaviour [UNRELEASED]

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

Variables are defined by prefixing a space separated word with a colon `:`.

You can do fancy stuff like root level args pretty easily:
```bash
$ cli @prod command
```

Which would be defined like:
```ruby
line('@:environment command')
```

### `--flag`, `-f`

### Boolean Flag [UNRELEASED]

### Value Flag

```ruby
line('build --env=:environment') do |environment|
  # The environment variable is now available.
end
```

### `subcommand`

Literal text will be interpreted as a subcommand.

```ruby
line('command subcommand') do
  # ...
end
```

### Summary block

Add a `summary` to a command, sub command or flag:

```ruby
line('static build') do
  summary { 'Build your static site' }
end
```
