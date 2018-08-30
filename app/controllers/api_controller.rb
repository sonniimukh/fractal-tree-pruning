class ApiController < ApplicationController
  
  def tree
    upstream_tree = UpstreamService::fetch_tree( request_params[:name] )

    tree = TreeService.prune(upstream_tree, request_params[:indicator_ids])

    # render html: ('<table><tr><td width="50%" valign="top"><pre>'+JSON.pretty_generate(upstream_tree)+'</pre></td><td width="50%" valign="top"><pre>'+JSON.pretty_generate(tree)+'</pre></td></tr></table>').html_safe and return

    render json: tree
  
  rescue ApplicationExceptions::UpstreamServiceError => e

    render json: {error: e.message}, status: :bad_gateway

  rescue ApplicationExceptions::UpstreamNotFoundError => e

    render json: {error: e.message}, status: :not_found

  end

  private

    def request_params
      params.permit(:name, indicator_ids: [])
    end

end
