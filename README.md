# Jekyll::VimHightlightBlock

Liquid tag for highlighting code using gvim.

## This is a pre-alpha project. Not recommended to install yet.

## Roadmap
- [x] Proof of concept
- [ ] Add tests
- [ ] Add dependencies docs
- [ ] Determine worthiness given it's slow, or how to make it faster


## Install (this does not work yet)

### 1. Add this line to your application's Gemfile:

    gem 'jekyll-vim-highlight'

### 2. Execute:

    $ bundle

Or install it yourself as:

    $ gem install jekyll-vim-highlight

### 3. Finally, add the following to your site's `_config.yml`:

```
gems:
  - jekyll-vim-highlight
```

## Usage

Use the tag as follows in your Jekyll pages, posts and collections:

```liquid
{% vim_highlight rb %}
```

## Contributing

Pull requests welcome!
