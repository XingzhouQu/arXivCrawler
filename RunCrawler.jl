using HTTP, Gumbo, AbstractTrees

function main()
    # 伪装成浏览器
    headers = Dict(
        "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.121 Safari/537.36"
    )

    r = HTTP.get("https://arxiv.org/list/cond-mat/new", headers=headers)

    r_parsed = parsehtml(String(r.body))
    titles = Vector{AbstractString}()
    abstracts = Vector{AbstractString}()

    root = r_parsed.root
    for elem in StatelessBFS(root)
        if isneed(elem, :div, "list-title mathjax")
            push!(titles, strip(elem.children[2].text))
            @assert strip(elem.children[2].text) isa AbstractString
            if isneed(elem, :p, "mathjax")
                push!(abstracts, strip(elem.children[1].text))
            end
        end
    end
    @show length(abstracts)  # ???

    # 这一页的总文章数
    @show length(titles)
    # 在这里指定搜索关键词
    filtedArticles = filter(x -> (contains(x, "\$_3\$Ni\$_2\$O") || contains(x, r"(?i)nickelate") || contains(x, r"(?i)mixed-dimensional") ||
    contains(x, r"\$_\{3\}\$Ni\$_\{2\}") || contains(x, r"Ruddlesden-Popper") || contains(x, r"Ni_\{2\}")), titles)
    # 选出来的文章数
    @info (length(filtedArticles), "important article(s)")
    for tit in filtedArticles
        println(tit)
    end

    filtedArticles = filter(x -> (contains(x, r"(?i)Superconduct") || contains(x, r"(?i)Hund")), titles)
    # 选出来的文章数
    @info (length(filtedArticles), "possible related articles")
    for tit in filtedArticles
        println(tit)
    end
end

function isneed(elem, label::Symbol, value::String)
    if isa(elem, HTMLElement) && tag(elem) == label && in(value, collect(values(attrs(elem))))
        return true
    end
    false
end

main()