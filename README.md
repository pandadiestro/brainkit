# Brainkit

<div align="center">

<div style="text-align: center;">

<img src="./docs/media/davinci.png" style="width: 300px;"/>

</div>

> *Tears come from the heart and not from the brain.*
>
> *-- Leonardo da Vinci*

</div>

Brainkit, right now, is a simple brainfuck interpreter CLI that follows
[this](https://github.com/sunjay/brainfuck/blob/master/brainfuck.md) (probably
unofficial) specification.

## Building

Build the project in releasesafe mode simply as

```sh
zig build -Doptimize=ReleaseSafe
```

## Usage

You can pass any file to Brainkit, it will always try to run it as brainfuck:

```sh
$ cat foo.bar.baz
++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.

$ /src/to/brainkit foo.bar.baz
Hello World!
```

You can also pipe to it with the single dash argument, like this:

```sh
$ cat foo.bar.baz
++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.

$ cat foo.bar.baz | /src/to/brainkit -
Hello World!
```

