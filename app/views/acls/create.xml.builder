xml.instruct!(:xml, version: '1.0', encoding: 'UTF-8')
xml.AccessControlPolicy(xmlns: 'http://s3.amazonaws.com/doc/2006-03-01/') do |acp|
  acp.Owner do |owner|
    owner.ID @bucket.user.id
    owner.DisplayName @bucket.user.name
  end
  acp.AccessControlList do |acl|
    acl.Grant do |grant|
      grant.Grantee('xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
                    'xsi:type' => 'CanonicalUser') do |grantee|
        grantee.ID @acl.id
        grantee.DisplayName @acl.name
      end
      grant.Permission @acl.permission
    end
  end
end
