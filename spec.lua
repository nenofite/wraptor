require('busted.runner')()

smartwrap = require 'smartwrap'

local long_text = [[
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus porttitor, ante eget cursus varius, dui odio placerat lacus, a ultricies nisl purus non mauris. Sed fermentum leo ipsum, eu fringilla libero ullamcorper id. Nullam vitae magna aliquam, placerat tortor ut, semper tortor. Nulla porttitor lobortis hendrerit. Nam eget lectus luctus, pellentesque dolor eu, dignissim nisi. Suspendisse commodo accumsan mi, eget suscipit tortor ultrices id. Maecenas interdum interdum augue, at dapibus nisl. Sed at dolor ut odio imperdiet semper. Morbi sed est eu ante pharetra ultricies eget faucibus urna. Praesent at bibendum lacus, quis sagittis massa. Duis ac vestibulum enim. Nulla.]]

local long_text_wrapped_40 = [[
Lorem ipsum dolor sit amet, consectetur
adipiscing elit. Phasellus porttitor,
ante eget cursus varius, dui odio
placerat lacus, a ultricies nisl purus
non mauris. Sed fermentum leo ipsum, eu
fringilla libero ullamcorper id. Nullam
vitae magna aliquam, placerat tortor
ut, semper tortor. Nulla porttitor
lobortis hendrerit. Nam eget lectus
luctus, pellentesque dolor eu,
dignissim nisi. Suspendisse commodo
accumsan mi, eget suscipit tortor
ultrices id. Maecenas interdum interdum
augue, at dapibus nisl. Sed at dolor ut
odio imperdiet semper. Morbi sed est eu
ante pharetra ultricies eget faucibus
urna. Praesent at bibendum lacus, quis
sagittis massa. Duis ac vestibulum
enim. Nulla.]]

local paragraphs = [[
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus porttitor, ante eget
cursus
varius,
dui
odio.

> Ante pharetra ultricies eget faucibus urna. Praesent at bibendum lacus, quis
> sagittis massa. Duis ac vestibulum.


]]

local paragraphs_wrapped = [[
Lorem ipsum dolor sit amet, consectetur
adipiscing elit. Phasellus porttitor,
ante eget cursus varius, dui odio.

> Ante pharetra ultricies eget faucibus
> urna. Praesent at bibendum lacus,
> quis sagittis massa. Duis ac
> vestibulum.


]]

describe("The function `wrap_text`", function()
  it("eliminates extra whitespace.", function()
    local lines = smartwrap.wrap_text("  \t \n", 40)
  
    assert.is_table(lines)
    assert.is_equal(0, #lines)
  end)

  it("wraps to the specified maximum line length.", function()
    local lines = smartwrap.wrap_text(long_text, 40)
    
    local lines_joined = ''
    
    for _, line in ipairs(lines) do
      lines_joined = lines_joined .. line .. '\n'
    end
  
    assert.is_equal(long_text_wrapped_40 .. '\n', lines_joined)
  end)
end)

describe("The function `wrap_paragraphs`", function()
  it("works the same as `wrap_text` for single-paragraph input text.", function()
    assert.is_equal(
      long_text_wrapped_40,
      smartwrap.wrap_paragraphs(long_text, 40)
    )
  end)
  
  it("wraps multiple-paragraph text.", function()
    assert.is_equal(
      paragraphs_wrapped,
      smartwrap.wrap_paragraphs(paragraphs, 40)
    )
  end)
end)