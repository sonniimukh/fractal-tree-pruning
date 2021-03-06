require 'test_helper'

class ApiControllerTest < ActionDispatch::IntegrationTest
  
  test 'should get valid tree' do
    get api_tree_url('input')
    assert_response :success
  end

  test 'should be 404 for invalid tree name' do
    get api_tree_url('noname')
    assert_response :not_found
  end

  test 'should not survive in case of repeated timeouts' do
    get api_tree_url('timeout')
    assert_response :bad_gateway
  end

  test 'should not survive in case of "derper" sample error' do
    get api_tree_url('derper')
    assert_response :bad_gateway
    assert_match 'Internal derper error', @response.body
  end

  test 'should handle non-JSON in upstream response' do
    get api_tree_url('not-a-json')
    assert_response :bad_gateway
  end

  test 'should handle JSON of a wrong structure in upstream response' do
    get api_tree_url('incorrect-json', indicator_ids: [1])
    assert_response :success
    json = JSON.parse(@response.body)
    assert_equal json, []
  end

  test 'should get [] if no indicator_ids provided' do
    get api_tree_url('input')
    assert_response :success
    json = JSON.parse(@response.body)
    assert_equal json, []
  end

  test 'should get only "Crude death rate"."total" in response for indicator_ids[]=1' do
    get api_tree_url('input', indicator_ids: [1])
    assert_response :success
    json = JSON.parse(@response.body)
    assert_equal json, JSON.parse('
      [
        {
          "id": 2, 
          "name": "Demographics", 
          "sub_themes": [
            {
              "categories": [
                {
                  "id": 11, 
                  "indicators": [
                    {
                      "id": 1, 
                      "name": "total"
                    }
                  ], 
                  "name": "Crude death rate", 
                  "unit": "(deaths per 1000 people)"
                }
              ], 
              "id": 4, 
              "name": "Births and Deaths"
            }
          ]
        }
      ]
    ')
  end

  test 'should disregard invalid indicator IDs' do
    get api_tree_url('input', indicator_ids: [1,'%$#','wrong'])
    assert_response :success
    json = JSON.parse(@response.body)
    assert_equal json, JSON.parse('
      [
        {
          "id": 2, 
          "name": "Demographics", 
          "sub_themes": [
            {
              "categories": [
                {
                  "id": 11, 
                  "indicators": [
                    {
                      "id": 1, 
                      "name": "total"
                    }
                  ], 
                  "name": "Crude death rate", 
                  "unit": "(deaths per 1000 people)"
                }
              ], 
              "id": 4, 
              "name": "Births and Deaths"
            }
          ]
        }
      ]
    ')
  end

  test 'should pass the example testing case' do
    get api_tree_url('input', indicator_ids: [31,32,1])
    assert_response :success
    json = JSON.parse(@response.body)
    assert_equal json, JSON.parse('
      [
        {
          "id": 2, 
          "name": "Demographics", 
          "sub_themes": [
            {
              "categories": [
                {
                  "id": 11, 
                  "indicators": [
                    {
                      "id": 1, 
                      "name": "total"
                    }
                  ], 
                  "name": "Crude death rate", 
                  "unit": "(deaths per 1000 people)"
                }
              ], 
              "id": 4, 
              "name": "Births and Deaths"
            }
          ]
        }, 
        {
          "id": 3, 
          "name": "Jobs", 
          "sub_themes": [
            {
              "categories": [
                {
                  "id": 23, 
                  "indicators": [
                    {
                      "id": 31, 
                      "name": "Total"
                    }, 
                    {
                      "id": 32, 
                      "name": "Female"
                    }
                  ], 
                  "name": "Unemployment rate, 15\u201324 years, usual", 
                  "unit": "(percent of labor force)"
                }
              ], 
              "id": 8, 
              "name": "Unemployment"
            }
          ]
        }
      ]
    ')
  end


end
