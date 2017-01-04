https://www.ejabberd.im/

This project fork from https://github.com/processone/ejabberd and custom some module and follow with ejabberd 16.12 release: 
https://blog.process-one.net/ejabberd-16-12/

Setup on ubuntu (test on Ubuntu 16.04)
---
Install erlang:
```bash
$ sudo apt-get install erlang
```

Install libyaml-dev
```bash
$ sudo apt-get install libyaml-dev
```

Compile source:
```bash
cd ejabberd
./autogen.sh
./configure
make
```
------------------

Create new ejabberd module
---

- Assume we installing ejabberd with Binary Installer (https://docs.ejabberd.im/admin/installation/).
place at: 
```bash
setupDir: /home/nhancao/Softs/ejabberd-16.12
```

- Ejabberd source code for build custom module place at:
```bash
sourceDir: /home/nhancao/Projects/nc-ejabberd-extra
```

*Note: replace `setupDir` and `sourceDir` correlative 

- Create module "hello_word"
    + Create _mod_hello_word.erl_ file and put it into `sourceDir/src` 
    + Content of _mod_hello_word.erl_ file:
    ```erlang
    -module(mod_hello_word).
    
    -behaviour(gen_mod).
    
    %% Required by ?INFO_MSG macros
    -include("logger.hrl").
    
    %% gen_mod API callbacks
    -export([start/2, stop/1]).
    
    start(_Host, _Opts) ->
        ?INFO_MSG("Hello, ejabberd world!", []),
        ok.
    
    stop(_Host) ->
        ?INFO_MSG("Bye bye, ejabberd world!", []),
        ok.
    ```
    
- cd to `sourceDir` and compile source or just run `make` if you've already complied.
- you'll get your mod's beam files in `sourceDir/ebin/` directory:
  `sourceDir/ebin/mod_hello_word.beam`
- copy the `mod_hello_word.beam` file generated above to `setupDir` using the following command:
```bash
sudo cp sourceDir/ebin/mod_hello_word.beam setupDir/lib/ejabberd-16.12/ebin/
```

- Add new module to config file place at: `setupDir/conf/ejabberd.yml`
```bash
mod_hello_word: {}
```

- Restart jabber server
- View log at:
`setupDir/logs/ejabberd.log`
and
`setupDir/logs/error.log`
    
Links
-----
- Wiki: https://github.com/nhancv/nc-ejabberd-extra/wiki




