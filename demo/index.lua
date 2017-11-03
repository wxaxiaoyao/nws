

-- 业务代码开始
nws.router("/", function(ctx)
	ctx.response:render("index.html", {message="Hello world"})
end)



