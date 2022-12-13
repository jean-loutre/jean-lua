from pathlib import Path
from luadoc.parser import DocParser, DocOptions
from luadoc.model import (
    LuaModule,
    LuaClass,
    LuaFunction,
    LuaParam,
    LuaTypeCallable,
    LuaType,
    LuaTypeAny,
    LuaTypeCustom,
    LuaTypeFunction
)
from snakemd import Document, InlineText, Header, Element, Table

source_root = Path.cwd() / "lua/jlua"
doc_root = Path.cwd() / "doc/api"


class RawElement(Element):
    def __init__(self, text):
        self._text = text

    def render(self):
        return self._text


def get_type_string(type_: LuaType):
    if isinstance(type_, LuaTypeAny):
        return "any"
    if isinstance(type_, LuaTypeCallable):
        arg_types = ", ".join([get_type_string(it) for it in type_.arg_types])
        return_types = list([get_type_string(it) for it in type_.return_types])

        if len(return_types) == 1:
            return_type = return_types[0]
        else:
            return_type = f"({', '.join(return_types)})"
        return f"function({arg_types}):{return_type}"
    if isinstance(type_, LuaTypeCustom):
        return type_.name
    if isinstance(type_, LuaTypeFunction):
        return type_.id

    assert(False)


def write_function(markdown: Document, method: LuaFunction, header_level: int):
    signature = "{name}({arguments})".format(
        name=method.name,
        arguments=", ".join([it.name for it in method.params]),
        returns=method.returns,
    )
    markdown.add_element(Header(InlineText(signature, code=True), level=header_level))

    markdown.add_paragraph(method.short_desc)
    test: LuaParam

    markdown.add_table(
        ["Parameter", "Type", "Description", "Default"],
        [
            [
                f"```{param.name}```" if param.is_opt else f"```{param.name}```*" ,
                f"```{get_type_string(param.type)}```",
                param.desc,
                param.default_value,
            ]
            for param in method.params
        ],
        align=[
            Table.Align.LEFT,
            Table.Align.LEFT,
            Table.Align.LEFT,
            Table.Align.CENTER,
        ],
    )

    markdown.add_element(RawElement(method.desc))


def write_class(
    markdown: Document,
    name: str,
    class_: LuaClass,
    header_level: int,
    short_desc: str | None = None,
    desc: str | None = None,
):
    markdown.add_header(f"{name}", header_level)
    if short_desc is None:
        short_desc = class_.short_desc
    if desc is None:
        short_desc = class_.desc
    markdown.add_paragraph(short_desc)

    markdown.add_element(RawElement(desc))

    if class_.fields:
        markdown.add_header("Fields", header_level + 1)

    if class_.methods:
        markdown.add_header("Methods", header_level + 1)

        for method in class_.methods:
            write_function(markdown, method, header_level + 2)

def write_module(markdown: Document, module: LuaModule):
    if module.is_class_mod:
        write_class(
            markdown,
            module.name,
            module.classes[0],
            1,
            short_desc=module.short_desc,
            desc=module.desc,
        )


for source_path in source_root.glob("**/*.lua"):
    doc_path = doc_root / source_path.relative_to(source_root).with_suffix(
        ""
    ).with_suffix(".md")

    doc_parser = DocParser(DocOptions())
    with open(source_path, "r") as source:
        module = doc_parser.build_module_doc_model(source.read(), str(source_path))

    markdown = Document(doc_path.name)
    write_module(markdown, module)

    doc_path.parent.mkdir(parents=True, exist_ok=True)
    with open(doc_path, "w") as doc:
        doc.write(str(markdown))