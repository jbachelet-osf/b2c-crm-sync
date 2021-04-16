'use strict';

const path = require('path');
const chai = require('chai');
const { expect } = chai;
const sinon = require('sinon');
const sinonTest = require('sinon-test');
sinon.test = sinonTest(sinon);
const sinonChai = require('sinon-chai');
chai.use(sinonChai);
const proxyquire = require('proxyquire').noCallThru();
require('dw-api-mock/demandware-globals');

describe('int_b2ccrmsync/cartridge/scripts/hooks/ocapi/shop.customer', function () {
    let sandbox;
    let spy;
    let requireStub;
    let customer;
    let shopCustomerHook;

    before('setup sandbox', function () {
        sandbox = sinon.createSandbox();
    });

    beforeEach(function () {
        requireStub = {
            'dw/system/Site': require('dw-api-mock/dw/system/Site'),
            'dw/system/HookMgr': require('dw-api-mock/dw/system/HookMgr')
        };
        shopCustomerHook = proxyquire(path.join(process.cwd(), 'src/sfcc/cartridges/int_b2ccrmsync/cartridge/scripts/hooks/ocapi/shop.customer'), requireStub);

        let Profile = require('dw-api-mock/dw/customer/Profile');
        let Customer = require('dw-api-mock/dw/customer/Customer');
        customer = new Customer(new Profile());
        spy = sinon.spy(require('dw-api-mock/dw/system/HookMgr'), 'callHook');
    });

    afterEach(function () {
        sandbox.restore();
        spy && spy.restore();
    });

    describe('afterPOST', function () {
        it('should not do anything in case the B2C CRM Sync site preference is disabled', function () {
            const site = require('dw-api-mock/dw/system/Site').getCurrent();
            site.customPreferences.b2ccrm_syncCustomersViaOCAPI = false;
            requireStub['dw/system/Site'].getCurrent = sandbox.stub().returns(site);
            shopCustomerHook.afterPOST(customer);

            expect(spy).to.have.not.been.called;
        });

        it('should not do anything in case the customer is not authenticated', function () {
            const site = require('dw-api-mock/dw/system/Site').getCurrent();
            site.customPreferences.b2ccrm_syncCustomersViaOCAPI = false;
            requireStub['dw/system/Site'].getCurrent = sandbox.stub().returns(site);
            customer.authenticated = false;
            shopCustomerHook.afterPOST(customer);

            expect(spy).to.have.not.been.called;
        });

        it('should call the HookMgr if the preference is enabled and the customer is authenticated', function () {
            const site = require('dw-api-mock/dw/system/Site').getCurrent();
            site.customPreferences.b2ccrm_syncCustomersViaOCAPI = true;
            requireStub['dw/system/Site'].getCurrent = sandbox.stub().returns(site);
            customer.authenticated = true;
            shopCustomerHook.afterPOST(customer);

            expect(spy).to.have.been.calledWith('app.customer.created', 'created', customer.getProfile());
        });
    });

    describe('afterPATCH', function () {
        it('should not do anything in case the B2C CRM Sync site preference is disabled', function () {
            const site = require('dw-api-mock/dw/system/Site').getCurrent();
            site.customPreferences.b2ccrm_syncCustomersViaOCAPI = false;
            requireStub['dw/system/Site'].getCurrent = sandbox.stub().returns(site);
            shopCustomerHook.afterPATCH(customer);

            expect(spy).to.have.not.been.called;
        });

        it('should not do anything in case the customer is not authenticated', function () {
            const site = require('dw-api-mock/dw/system/Site').getCurrent();
            site.customPreferences.b2ccrm_syncCustomersViaOCAPI = false;
            requireStub['dw/system/Site'].getCurrent = sandbox.stub().returns(site);
            customer.authenticated = false;
            shopCustomerHook.afterPATCH(customer);

            expect(spy).to.have.not.been.called;
        });

        it('should call the HookMgr if the preference is enabled and the customer is authenticated', function () {
            const site = require('dw-api-mock/dw/system/Site').getCurrent();
            site.customPreferences.b2ccrm_syncCustomersViaOCAPI = true;
            requireStub['dw/system/Site'].getCurrent = sandbox.stub().returns(site);
            customer.authenticated = true;
            shopCustomerHook.afterPATCH(customer);

            expect(spy).to.have.been.calledWith('app.customer.updated', 'updated', customer.getProfile());
        });
    });
});