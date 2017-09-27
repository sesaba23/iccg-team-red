# Iterative Crowdsourcing Comprehension Game

This is a Rails implementation of the ICCG game based on the paper _Paritosh,_
_P., & Marcus, G. (2016). Toward a comprehension challenge, using crowdsourcing_
_as a tool._ [AI Magazine, 37(1), 23-31.][0]

## Project Set Up

To ease up the start of the development process, you can use the the project's
virtual development environment based on Vagrant.

### First Run Usage

0. Install in your computer the software listed the requirements section.
1. Clone the repository into your machine.
2. Run `vagrant up` and wait for the machine to be built.
3. When the machine is ready, run `vagrant ssh` to log into it.
4. Move into the project directory with `cd /vagrant`.
5. Install the project gems with `bundle install`.
6. Build the database structure with `rails db:setup`.

Now check that everything works with `rails s` and opening http://localhost:3000
in your browser.

### Software Requirements

* [Vagrant][1]
* [Virtualbox][2] and the extension pack.

## Project Development

The _trunk development_ style is used on this repo, so follow the next steps to
work on new features and fixes:

* If using the virtual development environment:
  - Start the project's box with 'vagrant up'.
  - Log into the box with `vagrant ssh`.
  - Move into the project directory with `cd /vagrant`.
* Ensure dependencies are up to date:
  - `bundle install`
* Run pending migrations and load seed data:
  - `rails db:drop && rails db:setup`
* Create a new branch from the **master** branch.
* Try to work on atomic commits related to the feature.
* Try to add TDD and/or BDD tests for your code.
* On finish, send a push request from GitHub, targeting the **master** branch
  for review.

## Testing

This project relies on Rspec and Capybara. You can run the projects tests with
the `rake spec` command.

---
[0]: https://www.aaai.org/ojs/index.php/aimagazine/article/view/2649
[1]: https://www.vagrantup.com/downloads.html
[2]: https://www.virtualbox.org/wiki/Downloads
